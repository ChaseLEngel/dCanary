# Handles writing and querying a JSON lock file.

require 'json'

class Locker

	LOCKED = "1"
	UNLOCKED = "0"

	attr_accessor :lock_file, :json

	def initialize disks, options = {}
		# Take custom lock file or use default of script's directory/disks.lock
		@lock_file = options[:filename] || File.join(__dir__, "../disks.lock")
		@json = disks.clone.to_h
		# Initialize disks to 0.
		@json.map{|k, _| @json[k] = UNLOCKED}
		sync(disks) if File.exist?(@lock_file)
	end


	# Update @json hash to 1 and write it to lock file.
	def lock disk
		write do |f| 
			f.write(@json.update({disk => LOCKED}).to_json)
		end
	end

	# Update @json hash to 0 and write it to lock file.
	def unlock disk
		write do |f|
			f.write(@json.update({disk => UNLOCKED}).to_json)
		end
	end

	# Checks if disk is locked.
	# 1 = locked
	# 0 = unlocked
	def locked? disk
		@json.fetch(disk) == LOCKED
	end

	private

	# Make sure @json object and lock file match.
	def sync disks
		lock_file_json = File.open(@lock_file, "r"){ |f| JSON.parse(f.gets) }
		@json.merge!(lock_file_json)
		# Only keep disks that are in the config file.
		@json.keep_if{|disk,_| disks.include? disk}
		write do |f|
			f.write(@json.to_json)
		end
	end

	# Handle writing to lock file.
	def write
		file = File.new(@lock_file, "w")
		yield(file)
		file.close
	end

end