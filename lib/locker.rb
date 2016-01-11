# Handles writing and querying a JSON lock file.

require 'json'

class Locker

	attr_reader :lock_file, :json

	def initialize filename=nil, disks
		# Take custom lock file or use default of script's directory/disks.lock
		@lock_file = filename || File.join(__dir__, "disks.lock")
		@json = disks[:disks].clone
		# Replace config's limit values with locker's 0.
		@json.map{|k, v| @json[k] = 0}
		# If lock file already exists merge log file hash with config file hash.
		# Allows dCanary to pick-up from where it left off from last run.
		if File.exist? @lock_file
			lock_file_json = File.open(@lock_file, "r") do |f|
				JSON.parse(f.gets)
			end
			@json.merge!(lock_file_json)
			# Only keep disks that are in the config file.
			@json.keep_if{|disk,_| disks[:disks].include? disk}
			# Write out synced json.
			write do |f|
				f.write(@json.to_json)
			end
		end
	end

	# Handle writing to lock file.
	def write
		file = File.new(@lock_file, "w")
		yield(file)
		file.close
	end

	# Update @json hash disk key to 1 and write it to lock file.
	def lock disk
		write do |f| 
			f.write(@json.update({disk => "1"}).to_json)
		end
	end

	# Update @json hash disk key to 0 and write it to lock file.
	def unlock disk
		write do |f|
			f.write(@json.update({disk => "0"}).to_json)
		end
	end

	# Checks if disk is locked.
	# 1 = locked
	# 0 = unlocked
	def locked? disk
		@json[disk] == "1"
	end

end