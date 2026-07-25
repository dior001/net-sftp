# frozen_string_literal: true

require "common"

class Protocol::V04::TestName < Net::SFTP::TestCase
  def setup
    @save_tz   = ENV.fetch("TZ", nil)
    ENV["TZ"]  = "UTC"

    @directory      = name_fixture(:type => 2, :size => 1024, :permissions => 0o755)
    @link           = name_fixture(:type => 3, :size => 32, :permissions => 0o755)
    @file           = name_fixture(:type => 1, :size => 10240, :permissions => 0o755)
    @no_perms       = name_fixture(:type => 1, :size => 0, :permissions => 0)
    @world_writable = name_fixture(:type => 1, :size => 42, :permissions => 0o666)
  end

  def teardown
    if @save_tz
      ENV["TZ"] = @save_tz
    else
      ENV.delete("TZ")
    end
  end

  def test_directory?
    assert_predicate @directory, :directory?
    refute_predicate @link, :directory?
    refute_predicate @file, :directory?
  end

  def test_symlink?
    refute_predicate @directory, :symlink?
    assert_predicate @link, :symlink?
    refute_predicate @file, :symlink?
  end

  def test_file?
    refute_predicate @directory, :file?
    refute_predicate @link, :file?
    assert_predicate @file, :file?
  end

  def test_longname_for_directory_should_format_as_directory
    assert_equal "drwxr-xr-x jamis    users        1024 Mar 12 03:40 test",
                 @directory.longname
  end

  def test_longname_for_symlink_should_format_as_symlink
    assert_equal "lrwxr-xr-x jamis    users          32 Mar 12 03:40 test",
                 @link.longname
  end

  def test_longname_for_file_should_format_as_file
    assert_equal "-rwxr-xr-x jamis    users       10240 Mar 12 03:40 test",
                 @file.longname
  end

  def test_longname_with_no_permission_bits_set_should_format_with_all_dashes
    assert_equal "---------- jamis    users           0 Mar 12 03:40 test",
                 @no_perms.longname
  end

  def test_longname_with_group_and_other_write_bits_set_should_format_as_writable
    assert_equal "-rw-rw-rw- jamis    users          42 Mar 12 03:40 test",
                 @world_writable.longname
  end

  private

  def name_fixture(attrs)
    Net::SFTP::Protocol::V04::Name.new(
      "test",
      Net::SFTP::Protocol::V04::Attributes.new({ :mtime => 1205293237, :owner => "jamis", :group => "users" }.merge(attrs))
    )
  end
end
