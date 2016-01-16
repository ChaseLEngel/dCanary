require 'minitest/autorun'

require_relative '../lib/disk_helper.rb'

class TestDiskHelper < Minitest::Test

	def test_percent_returns_number
		disk = "/dev/disk1"
		assert_kind_of Fixnum, DiskHelper.percent(disk)
	end


	def test_percent_with_bad_disk
		disk = "/not/a/disk"
		assert_raises(DiskHelper::ShellCommandError) do
			DiskHelper.percent(disk)
		end
	end

	def test_free_returns_string
		disk = "/dev/disk1"
		assert_kind_of String, DiskHelper.free(disk)
	end

	def test_free_with_bad_disk
		disk = "/not/a/disk"
		assert_raises(DiskHelper::ShellCommandError) do
			DiskHelper.free(disk)
		end
	end

	def test_hostname_returns_string
		assert_kind_of String, DiskHelper.hostname
	end

end