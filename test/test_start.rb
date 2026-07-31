# frozen_string_literal: true

require "common"

class StartTest < Net::SFTP::TestCase
  def test_with_block
    ssh = mock("ssh")
    ssh.expects(:close)
    Net::SSH.expects(:start).with("host", "user", {}).returns(ssh)

    sftp = mock("sftp")
    # TODO: figure out how to verify a block is passed, and call it later.
    # I suspect this is hard to do properly with mocha.
    Net::SFTP::Session.expects(:new).with(ssh, nil).returns(sftp)
    sftp.expects(:connect!).returns(sftp)
    sftp.expects(:loop)

    Net::SFTP.start("host", "user") do
      # NOTE: currently not called!
    end
  end

  def test_with_block_and_options
    ssh = mock("ssh")
    ssh.expects(:close)
    Net::SSH.expects(:start).with("host", "user", { auth_methods: ["password"] }).returns(ssh)

    sftp = mock("sftp")
    Net::SFTP::Session.expects(:new).with(ssh, 3).returns(sftp)
    sftp.expects(:connect!).returns(sftp)
    sftp.expects(:loop)

    Net::SFTP.start("host", "user", { auth_methods: ["password"] }, { version: 3 }) do
      # NOTE: currently not called!
    end
  end

  def test_without_block_should_return_connected_session_without_closing_it
    ssh = mock("ssh")
    Net::SSH.expects(:start).with("host", "user", {}).returns(ssh)

    sftp = mock("sftp")
    Net::SFTP::Session.expects(:new).with(ssh, nil).returns(sftp)
    sftp.expects(:connect!).returns(sftp)
    sftp.expects(:loop).never
    ssh.expects(:close).never

    assert_equal sftp, Net::SFTP.start("host", "user")
  end

  def test_when_error_occurs_before_session_is_established_should_reraise_without_shutdown
    Net::SSH.expects(:start).raises(RuntimeError, "boom")

    assert_raises(RuntimeError) { Net::SFTP.start("host", "user") }
  end

  def test_when_error_occurs_after_session_is_established_should_shutdown_session_and_reraise
    ssh = mock("ssh")
    ssh.expects(:shutdown!)
    Net::SSH.expects(:start).with("host", "user", {}).returns(ssh)
    Net::SFTP::Session.expects(:new).raises(RuntimeError, "boom")

    assert_raises(RuntimeError) { Net::SFTP.start("host", "user") }
  end

  def test_ssh_connection_session_sftp_extension_connects_and_memoizes_by_default
    expect_sftp_session

    assert_scripted do
      result = connection.sftp
      assert_kind_of Net::SFTP::Session, result
      assert_predicate result, :open?
      assert_same result, connection.sftp
    end
  end

  def test_ssh_connection_session_sftp_extension_does_not_connect_when_wait_is_false
    expect_sftp_session

    Net::SSH::Test::Extensions::IO.with_test_extension do
      result = connection.sftp(false)
      assert_kind_of Net::SFTP::Session, result
      refute_predicate result, :open?
    end
  end
end
