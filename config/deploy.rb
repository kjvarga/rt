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
set :repository,  "git@github.com:kjvarga/rottentorrentz.git"
set :domain,      "varzyfamily.com"
set :user,        "kjvarga" # login name for the shared host.  it should also be the name of your home directory.
set :use_sudo,    false     # no access to sudo on a shared host

#
# Custom Variables
#
set :application_symlink, "/home/#{user}/public_html/rottentorrentz.varzyfamily.com" # symlink the current release public folder to here

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
after "deploy:update_code", :update_permissions_on_public
after "deploy:cold",        :create_application_symlink

desc "chmod 755 the public/ folder and the public/dispatch.* files."
task :update_permissions_on_public, :roles => [:app] do
  run "chmod 755 #{release_path}/public"
  run "chmod 755 #{release_path}/public/dispatch.*"
end

desc "Symlink the current release's public/ folder to a directory in public_html."
task :create_application_symlink, :roles => [:app] do
  run "ln -fs #{current_path}/public #{application_symlink}"
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
      delete_files "#{logfile}.bz2"
    end
  end
end

#
# Helpers
#
def timestamp_string
  Time.now.strftime("%Y%m%d%H%M%S")
end

def delete_files(*args)
  run "rm -f #{args.join(' ')}"
end