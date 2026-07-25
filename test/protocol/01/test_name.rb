# frozen_string_literal: true

require "common"

class Protocol::V01::TestName < Net::SFTP::TestCase
  def setup
    @directory = Net::SFTP::Protocol::V01::Name.new("test", "drwxr-x-r-x  89 test  test  3026 Mar 10 17:45 test",
                                                    Net::SFTP::Protocol::V01::Attributes.new(:permissions => 0o40755))
    @link      = Net::SFTP::Protocol::V01::Name.new("test", "lrwxr-x-r-x  89 test  test  3026 Mar 10 17:45 test",
                                                    Net::SFTP::Protocol::V01::Attributes.new(:permissions => 0o120755))
    @file      = Net::SFTP::Protocol::V01::Name.new("test", "-rwxr-x-r-x  89 test  test  3026 Mar 10 17:45 test",
                                                    Net::SFTP::Protocol::V01::Attributes.new(:permissions => 0o100755))
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
end
