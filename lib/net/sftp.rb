# frozen_string_literal: true

require "net/ssh"
require "net/sftp/session"

module Net
  # Net::SFTP is a pure-Ruby module for programmatically interacting with a
  # remote host via the SFTP protocol (that's SFTP as in "Secure File Transfer
  # Protocol" produced by the Secure Shell Working Group, not "Secure FTP"
  # and certainly not "Simple FTP").
  #
  # See Net::SFTP#start for an introduction to the library. Also, see
  # Net::SFTP::Session for further documentation.
  module SFTP
    # A convenience method for starting a standalone SFTP session. It will
    # start up an SSH session using the given arguments (see the documentation
    # for Net::SSH::Session for details), and will then start a new SFTP session
    # with the SSH session. This will block until the new SFTP is fully open
    # and initialized before returning it.
    #
    #   sftp = Net::SFTP.start("localhost", "user")
    #   sftp.upload! "/local/file.tgz", "/remote/file.tgz"
    #
    # If a block is given, it will be passed to the SFTP session and will be
    # called once the SFTP session is fully open and initialized. When the
    # block terminates, the new SSH session will automatically be closed.
    #
    #   Net::SFTP.start("localhost", "user") do |sftp|
    #     sftp.upload! "/local/file.tgz", "/remote/file.tgz"
    #   end
    #
    # Extra parameters can be passed:
    # - The Net::SSH connection options (see Net::SSH for more information)
    # - The Net::SFTP connection options (only :version is supported, to let you
    #   set the SFTP protocol version to be used)
    def self.start(host, user, ssh_options = {}, sftp_options = {}, &)
      session = Net::SSH.start(host, user, ssh_options)
      # We only use a single option here, but this leaves room for more later
      # without breaking the external API.
      version = sftp_options.fetch(:version, nil)
      sftp = Net::SFTP::Session.new(session, version, &).connect!

      if block_given?
        sftp.loop
        session.close
        return nil
      end

      sftp
    rescue Object => e
      # Must shut down the SSH session on *any* error, including
      # non-StandardError ones (e.g. Interrupt) raised while connecting.
      begin
        session.shutdown!
      rescue ::Exception # rubocop:disable Lint/RescueException -- deliberately swallow anything raised while shutting down; the original error from above is what should propagate
        # swallow exceptions that occur while trying to shutdown
      end

      raise e
    end
  end
end

# rubocop:disable Style/OneClassPerFile -- this reopening belongs with Net::SFTP.start above; it is the other half of the same "convenient top-level entry point" feature
class Net::SSH::Connection::Session
  # A convenience method for starting up a new SFTP connection on the current
  # SSH session. Blocks until the SFTP session is fully open, and then
  # returns the SFTP session.
  #
  #   Net::SSH.start("localhost", "user", :password => "password") do |ssh|
  #     ssh.sftp.upload!("/local/file.tgz", "/remote/file.tgz")
  #     ssh.exec! "cd /some/path && tar xf /remote/file.tgz && rm /remote/file.tgz"
  #   end
  def sftp(wait = true)
    @sftp ||= begin
      sftp = Net::SFTP::Session.new(self)
      sftp.connect! if wait
      sftp
    end
  end
end
# rubocop:enable Style/OneClassPerFile
