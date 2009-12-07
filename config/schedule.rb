# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :cron_log, "~/sites/rottentorrentz/current/log/cron_log.log"

every 3.days do
  rake "-s sitemap:refresh"
end

# Touch some pages every so often to keep the data 
# fresh and ensure the site is alive
every 2.hours do
  rake "app:ping"
end

every 1.day do
  command "mongrel_rails restart -P /home/kjvarga/sites/rottentorrentz/current/tmp/pids/mongrel_rails.3000.pid"
end

every :reboot do
  command 'mongrel_rails start -C /home/kjvarga/sites/rottentorrentz/current/config/mongrel.yml'
end
