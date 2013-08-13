#!/usr/bin/env ruby

require 'syslog'
require 'nats/client'

syslog = Syslog.open('vcap.nats', Syslog::LOG_PID, Syslog::LOG_USER)

%w[TERM INT].each do |sig|
  trap(sig) do
    NATS.stop
  end
end

NATS.start(:uri => ARGV[0]) do
  NATS.subscribe(">") do |message, _, subject|
    json = %Q[{"timestamp": #{Time.now.to_f},"subject": #{subject},"message": #{message}}]
    syslog.log(Syslog::LOG_INFO, json)
  end
end