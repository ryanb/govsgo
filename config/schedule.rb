set :output, "#{path}/log/cron.log"

every :reboot do
  command "god -c #{path}/config/god.rb"
end

every 1.hour do
  rake "queue_computer_moves" # just in case some computer moves slipped through the cracks
end
