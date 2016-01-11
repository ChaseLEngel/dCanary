require 'fileutils'
require 'minitest/autorun'
require 'yaml'
require_relative '../lib/locker.rb'

class TestLocker < Minitest::Test

	def setup
		@config = YAML.load_file "test_config.yml"
		@locker = Locker.new disks: @config["disks"]
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

	def teardown
		FileUtils.rm @locker.lock_file if File.exist? @locker.lock_file
	end

end

