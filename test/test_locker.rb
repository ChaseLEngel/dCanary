require 'fileutils'
require 'minitest/autorun'
require 'yaml'
require_relative '../lib/locker.rb'

class TestLocker < Minitest::Test

	def setup
		@config = YAML.load_file File.dirname(__FILE__) + "/test_config.yml"
		@locker = Locker.new @config["disks"]
		@random_disk = Proc.new { @config["disks"].keys.sample }
	end

	def test_lock
		disk = @random_disk.call
		@locker.lock disk
		expected = "1"
		actual = JSON.parse(File.new(@locker.lock_file, "r").gets)[disk]
		assert_equal expected, actual
	end

	def test_unlock
		disk = @random_disk.call
		@locker.unlock disk
		expected = "0"
		actual = JSON.parse(File.new(@locker.lock_file, "r").gets)[disk]
		assert_equal expected, actual
	end

	def test_locked_defaults_to_false
		assert !@locker.locked?(@random_disk.call), "Should be false."
	end

	def test_locked_true
		@locker.json.update({"/dev/disk1" => "1"})
		assert @locker.locked?("/dev/disk1"), "Locked? should return true."
	end

	def test_locked_false
		@locker.json.update({"/dev/disk1" => "0"})
		assert !@locker.locked?("/dev/disk1"), "Locked? should return false."
	end

	def teardown
		FileUtils.rm @locker.lock_file if File.exist? @locker.lock_file
	end

end
