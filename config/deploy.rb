#
# KJV, June 20, 2009
# Custom deploy script for HostGator using Git, Sqlite and FCGI.
#
# Adapted from http://blog.spoolz.com/2008/05/28/update-capistrano-deploy-for-shared-hosting-with-git-repository/
#
# @see http://www.opensourceconnections.com/2007/03/01/using-sqlite3-capistrano-mongrel-cluster-oh-my/ for Sqlite3 db setup.
# @see http://github.com/collectiveidea/awesome-backup/tree/master for automated db backups

#
# Capistrano Dependencies.
#
# Use capistrano_rsync_with_remote_cache for a special deployment strategy.
#
depend :local, :gem, "capistrano_rsync_with_remote_cache", ">=2.3.4"

#
# SSH Setup
#
ssh_options[:port] =     2222
ssh_options[:paranoid] = false

#
# Names, Paths and Logins
#
set :application, "rottentorrentz"
set :repository,  "git@github.com:kjvarga/rt.git"
set :domain,      "varzyfamily.com"
set :user,        "kjvarga" # login name for the shared host.  it should also be the name of your home directory.
set :use_sudo,    false     # no access to sudo on a shared host

#
# Custom Variables
#
set :application_symlink, "/home/#{user}/public_html/rottentorrentz.com" # symlink the current release public folder to here
set :rails_env, 'production'

#
# Deployment Setup
#
set :deploy_via,        :rsync_with_remote_cache
set :rsync_options,     " -az -e 'ssh -p 2222 ' --delete " # non-standard SSH port.  the space after the port numnber is required!
set :deploy_to,         "/home/#{user}/sites/#{application}"
set :copy_exclude,      [".git", ".gitignore"]
set :copy_compression,  :gzip   # compress using gzip when synchronizing the remote cache
set :keep_releases, 20          # keep this many previous releases

#
# SCM Setup
#
set :scm, :git
set :git_shallow_clone, 1       # only copy the most recent, not the entire repository (default:1)

#
# Roles and the associated Domains
#
role :app, "varzyfamily.com"
role :web, "varzyfamily.com"
role :db,  "varzyfamily.com", :primary => true  # primary database

#
# Tasks
#
before "deploy",             :disable_web
after  "deploy:cold",        :create_application_symlink
after  "deploy:setup",       :create_application_symlink
after  "deploy:update_code", 'sass:update'
after  'deploy:update_code', :symlink_sitemap_to_public
after  "deploy:symlink",     "whenever:update_crontab"
after  "deploy",             :enable_web

task :disable_web, :roles => [:web] do find_and_execute_task('deploy:web:disable'); end
task :enable_web,  :roles => [:web] do find_and_execute_task('deploy:web:enable');  end

desc "Symlink the sitemap files from shared/system/ to the application's public/ folder."
task :symlink_sitemap_to_public, :roles => [:app] do
  run "ln -fs #{shared_path}/system/sitemap* #{current_path}/public"
end

desc "Symlink the current release's public/ folder to subdomain directory in public_html."
task :create_application_symlink, :roles => [:app] do
  run "ln -fs #{current_path}/public #{application_symlink}"
end

desc "After setup ensure the shared/db and shared/backups folders exist."
task :after_setup, :roles => [:app, :db, :web] do
  run "umask 02 && mkdir -p #{shared_path}/db && mkdir -p #{shared_path}/backups"
end

desc "Invoke a rake task on the remote server.  Call with TASK=the:task:name"
task :invoke do
  run("cd #{latest_release}; RAILS_ENV=#{rails_env} rake #{ENV['TASK']}")
end

namespace :whenever do
  desc "Update the crontab file for whenever scheduled tasks."
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end
  
desc <<-DESC
  Parse the enviroment files and for those gems that we want to use the
  system gem, delete the local gem from vendor/gems.  To mark a local gem for
  deletion, add a :use_system_gem => true option to your config.gem statement
  in either environment.rb or production.rb.  You may need to do this when you
  have an unpacked gem but no access to a compiler, so you cannot build it.
  To force Rails to use the system/local gem you have to remove the unpacked gem.
DESC
task :delete_local_copy_of_system_gems do
  ["#{release_path}/config/environment.rb", "#{release_path}/config/environments/production.rb"].each do |file|
    cmd = <<-CMD
      grep 'config.gem.*:use_system_gem => true' #{file} |\
      sed 's/[ ^I]*config.gem[ ^I]*['\\''"]\\([^'\\''"]*\\)['\\''\"].*/\\1/'
    CMD
    gems = []
    run cmd do |channel, stream, data|
      gems = data.split()
    end
    gems.each do |gem|
      run "rm -rf #{release_path}/vendor/gems/#{gem}*"
    end
  end
end

desc "After updating the code, do some housekeeping."
task :after_update_code, :roles => [:app, :db, :web] do
  
  # chmod 755 the public/ folder and the public/dispatch.* files.
  run "chmod 755 #{release_path}/public"
  run "chmod 755 #{release_path}/public/dispatch.*"
  
  # Switch to production environment.
  # This uncomments all lines in environment.rb that start with '#prod'
  environment_file = "#{release_path}/config/environment.rb"
  run "sed 's/^#prod//g' #{environment_file} > #{environment_file}.tmp && mv #{environment_file}.tmp #{environment_file}"
  
  # Delete unpacked native gems.  Because we don't have access to the C compiler
  # on HostGator, we cannot build the unpacked gems.  So we must use the system gem.
  delete_local_copy_of_system_gems
end

#
# SASS
#
namespace :sass do
  desc "Updates the stylesheets generated by Sass"
  task :update, :roles => [:app] do
    run "rake -f #{current_path}/Rakefile sass:update RAILS_ENV=production"
  end
end

#
# Deploy
#
# Override the default start/stop/restart functions for a shared host
# running FCGI processes.
#
namespace :deploy do
  desc "Restart the web server. Simply kill all FCGI processes."
  task :restart, :roles => :app do
    run "killall -q dispatch.fcgi"
  end

  desc "Start the web server. Symlink the application and kill all \
        FCGI processes.  Otherwise nothing to do here for shared hosting."
  task :start, :roles => :app do
    create_application_symlink
    deploy.restart
  end

  desc "Stop the web server.  Does nothing but override the default."
  task :stop, :roles => :app do
  end
end
  
#
# Log
#
# Backup and truncate the production logs.
#
namespace :log do
  desc "Compress and copy log file to local machine"
  task :rotate, :roles => [:app] do
    logfiles = capture( "ls -x #{shared_path}/log" ).split

    if logfiles.index( 'production.log' ).nil?
      logger.info "production.log was not found, no rotation performed"

    else
      filename = "production.log.#{timestamp_string}.log.bz2"
      logfile = "#{shared_path}/log/production.log"

      deploy.restart # stop the server
      run "bzip2 #{logfile}" # bzips the production.log and removes it

      `mkdir -p #{File.dirname(__FILE__)}/../backups/log`
      download "#{logfile}.bz2", "backups/log/#{filename}"
      run "rm -f #{logfile}.bz2"
    end
  end
end

#
# Helpers
#
def timestamp_string
  Time.now.strftime("%Y%m%d%H%M%S")
end