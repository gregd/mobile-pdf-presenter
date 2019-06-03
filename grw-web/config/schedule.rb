# http://en.wikipedia.org/wiki/Cron
# http://github.com/javan/whenever

set :output, "log/cron.log"

every :reboot do
  command "cd #{path} && RAILS_ENV=production bin/delayed_job start"
end

every 1.day, :at => "3:05 am" do
  command "cd #{path} && RAILS_ENV=production bin/delayed_job restart"
end

