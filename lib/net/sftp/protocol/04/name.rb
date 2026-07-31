# frozen_string_literal: true

module Net; module SFTP; module Protocol; module V04
  # Represents a single named item on the remote server. This includes the
  # name, and attributes about the item, and the "longname".
  #
  # For backwards compatibility with the format and interface of the Name
  # structure from previous protocol versions, this also exposes a #longname
  # method, which returns a string that can be used to display this item in
  # a directory listing.
  class Name
    # The name of the item on the remote server. Writable so that
    # Net::SFTP::Operations::Dir#glob can rewrite it to a path relative to
    # the directory it started searching from, as it descends into
    # subdirectories.
    attr_accessor :name

    # Attributes instance describing this item.
    attr_reader :attributes

    # Create a new Name object with the given name and attributes.
    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end

    # Returns +true+ if the item is a directory.
    def directory?
      attributes.directory?
    end

    # Returns +true+ if the item is a symlink.
    def symlink?
      attributes.symlink?
    end

    # Returns +true+ if the item is a regular file.
    def file?
      attributes.file?
    end

    # Returns a string representing this file, in a format similar to that
    # used by the unix "ls" utility.
    def longname
      @longname ||= begin
        type = if directory?
          "d"
        elsif symlink?
          "l"
        else
          "-"
        end

        permissions = [
          (attributes.permissions.nobits?(0o400) ? "-" : "r"),
          (attributes.permissions.nobits?(0o200) ? "-" : "w"),
          (attributes.permissions.nobits?(0o100) ? "-" : "x"),
          (attributes.permissions.nobits?(0o040) ? "-" : "r"),
          (attributes.permissions.nobits?(0o020) ? "-" : "w"),
          (attributes.permissions.nobits?(0o010) ? "-" : "x"),
          (attributes.permissions.nobits?(0o004) ? "-" : "r"),
          (attributes.permissions.nobits?(0o002) ? "-" : "w"),
          (attributes.permissions.nobits?(0o001) ? "-" : "x")
        ].join

        [
          type,
          permissions,
          format(" %<owner>-8s %<group>-8s %<size>8d ", owner: attributes.owner, group: attributes.group, size: attributes.size),
          Time.at(attributes.mtime).strftime("%b %e %H:%M "),
          name
        ].join
      end
    end
  end
end; end; end; end
