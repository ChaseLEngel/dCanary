# Collection of methods that get information from host machine.

module DiskHelper

	# Extend self.	
	module_function

	ShellCommandError = Class.new(StandardError)

	# Get the percentage of the disk
	# df -h - Shows stats for given disk
	# \grep - Grep df output and ignore any alias for grep
	# awk '{print $5}' - To print 5th column
	# tail -1 - Only display line with percentage
	# tr -d % - Remove percent character
	def percent disk
		percent = `df -h | \grep #{disk} | awk '{print $5}' | tail -1 | tr -d %`
		raise ShellCommandError, "Can't get percent of #{disk}" if percent.empty?
		percent.to_i
	end

	# Get amount of space left on a disk.
	def free disk
		free = `df -h | \grep #{disk} | awk '{print $4}'`.chomp
		raise ShellCommandError, "Can't get free space of #{disk}" if free.empty?
		free
	end

	def hostname
		hostname = `hostname`.chomp
		raise ShellCommandError, "Can't get hostname." if hostname.empty?
		hostname
	end

end