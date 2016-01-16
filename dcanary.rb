#!/usr/bin/env ruby

require "yaml"
require "rest-client"

require_relative 'lib/locker.rb'
require_relative 'lib/disk_helper.rb'


config = YAML.load_file(File.dirname(__FILE__) + "/config.yml")

config_variables = %w[telegram_api_token telegram_chat_id disks]

# Check config file correctness.
config_variables.each do |var|
	if config[var].nil?
		puts "[ERROR]: Please set '#{var}' in config file."
		exit(1)
	end
end

locker = Locker.new config["disks"]

@token = config["telegram_api_token"]
@chat_id = config["telegram_chat_id"]

# Send a Telegram message
def sendMessage disk
	message = "#{DiskHelper.hostname} has disk #{disk} that is #{DiskHelper.percent(disk)}% full, #{DiskHelper.free(disk)} left."
	url = "https://api.telegram.org/bot#{@token}/sendMessage"
	RestClient.post url, {:chat_id => @chat_id, :text => message}
end

# Disk is over limit and unlocked.
# Send message and lock that disk.
config["disks"]
	.select{ |disk, limit| DiskHelper.percent(disk) >= limit.to_i && !locker.locked?(disk) }
	.each do |disk, limit|
		sendMessage(disk)
		locker.lock(disk)
	end

# Disk is under limit and locked.
# Unlock that disk.
config["disks"].select{ |disk, limit| DiskHelper.percent(disk) < limit.to_i && locker.locked?(disk) }
	.each{ |disk, limit| locker.unlock(disk) }
