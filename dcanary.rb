#!/usr/bin/env ruby

require "yaml"
require "rest-client"
require_relative 'lib/locker.rb'

config = YAML.load_file("config.yml")

locker = Locker.new disks: config["disks"]

# Set variables for Telegram API.
@token = config["telegram_api_token"]
@chat_id = config["telegram_chat_id"]
if @token.nil? || @chat_id.nil?
	puts "[ERROR]: Please set \"telegram_api_token\" AND \"telegram_chat_id\" in config file."
	exit(1)
end

# Send a Telegram message
def sendMessage disk
	message = "#{hostname} has disk #{disk} that is #{percent(disk)}% full, #{amountLeft(disk)} left."
	url = "https://api.telegram.org/bot#{@token}/sendMessage"
	RestClient.post url, {:chat_id => @chat_id, :text => message}
end

# Get the percentage of the disk
# df -h - Shows stats for given disk
# \grep - Grep df output and ignore any alias for grep
# awk '{print $5}' - To print 5th column
# tail -1 - Only display line with percentage
# tr -d % - Remove percent character
def percent disk
	`df -h | \grep #{disk} | awk '{print $5}' | tail -1 | tr -d %`.to_i
end

# Get amount of space left on a disk.
def amountLeft disk
	`df -h | \grep #{disk} | awk '{print $4}'`.chomp
end

# Get hostname of the machine.
def hostname
	`hostname`.chomp
end

# Disk is over limit and unlocked.
# Send message and lock that disk.
config["disks"]
	.select{ |disk, limit| percent(disk) >= limit.to_i and not locker.locked?(disk) }
	.each do |disk, limit|
		sendMessage(disk)
		locker.lock(disk)
	end

# Disk is under limit and locked.
# Unlock that disk.
config["disks"].select{ |disk, limit| percent(disk) < limit.to_i and locker.locked?(disk) }
	.each{ |disk, limit| locker.unlock(disk) }
