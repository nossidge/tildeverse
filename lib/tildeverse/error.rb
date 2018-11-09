#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Namespace module for the Tildeverse exception hierarchy
  #
  # All exceptions are descendants of this class
  #
  # All errors should have short messages
  # {Tildeverse::Error#message}
  # for developers using the gem, and longer messages
  # {Tildeverse::Error#console_message}
  # for end users who will be using the bin through the console
  #
  # If accessing through a console, all these errors are cause to exit
  #
  class Error < StandardError
    def initialize(msg)
      super msg
    end

    # @method message
    # @return [String] short message for developers

    # @return [String] longer message for command line output
    def console_message
      %(ERROR: #{message})
    end

    # Message to append to console output if the error is all my fault
    def developer_error
      <<-MSG.gsub(/^ {8}/, '') + developer_issue
               Developer error! You should not be seeing this!
      MSG
    end

    # Message to append to console output if the error is not my fault,
    # but does need my coding attention
    def developer_issue
      <<-MSG.gsub(/^ {8}/, '')
               I'd be very grateful if you'd log this issue at:
               https://github.com/nossidge/tildeverse/issues
               Thanks,
                 ~nossidge
      MSG
    end

    ############################################################################

    ##
    # Error class raised when an operation is attempted for which the user
    # does not have appropriate file permissions
    #
    # This would include: attempting to save the tildeverse data to file,
    # generating the output webpage files, or altering the 'config.yml'
    #
    class PermissionDeniedError < Error
      def initialize(msg = message)
        super msg
      end

      # (see Tildeverse::Error#message)
      def message
        %(Current user is not authorised to perform this task)
      end
    end

    ##
    # Error class raised when a user is denied write-access by 'config.yml'
    #
    class DeniedByConfig < PermissionDeniedError
      def initialize(msg = message)
        super msg
      end

      # (see Tildeverse::Error#console_message)
      def console_message
        <<~MSG
          ERROR: The current user is not authorised to perform this task.
                 You do not have the appropriate permissions to amend data.
                 Update the file 'config.yml' to add or remove usernames
                 from the white-list.
        MSG
      end
    end

    ##
    # Error class raised when a user is denied write-access by the OS
    #
    class DeniedByOS < PermissionDeniedError
      def initialize(msg = message)
        super msg
      end

      # (see Tildeverse::Error#console_message)
      def console_message
        <<~MSG
          ERROR: The current user is not authorised to perform this task.
                 You do not have the appropriate permissions to amend data.
                 You must ask your administrator to permit write-access to
                 the appropriate directories.
        MSG
      end
    end

    ############################################################################

    ##
    # Error class raised when a URI is invalid
    #
    class URIError < Error
      #
      # Invalid URI that was attempted
      attr_reader :uri

      def initialize(uri, msg = nil)
        @uri = uri
        super msg || message
      end
    end

    ##
    # Error class raised on invalid URI input
    #
    class InvalidURIError < URIError

      # (see Tildeverse::Error#message)
      def message
        %(Tilde URI must be HTTP or HTTPS: "#{uri}")
      end

      # (see Tildeverse::Error#console_message)
      def console_message
        <<~MSG + developer_error
          ERROR: Invalid URL encounted for Tilde site:
                   "#{uri}"
        MSG
      end
    end

    ##
    # Error class raised when a URI is offline
    #
    class OfflineURIError < URIError

      # (see Tildeverse::Error#message)
      def message
        %(URI is offline: "#{uri}")
      end

      # (see Tildeverse::Error#console_message)
      def console_message
        <<~MSG + developer_issue
          ERROR: Tilde site apears to be offline:
                   "#{uri}"
        MSG
      end
    end

    ############################################################################

    ##
    # Error class raised when a 'config.yml' file is read incorrectly
    #
    class ConfigError < Error
      def console_message
        super + "\n" + <<-MSG.gsub(/^ {10}/, '')
                 Update the file 'config.yml' and correct this field
        MSG
      end
    end

    ##
    # Error class raised when {Config#authorised_users} is invalid
    #
    class AuthorisedUsersError < ConfigError
      def initialize
        super %('authorised_users' must be a valid list of users)
      end
    end

    ##
    # Error class raised when {Config#update_type} is invalid
    #
    class UpdateTypeError < ConfigError
      def initialize
        super %('update_type' must be one of: scrape, fetch)
      end
    end

    ##
    # Error class raised when {Config#update_frequency} is invalid
    #
    class UpdateFrequencyError < ConfigError
      def initialize
        super %('update_frequency' must be one of: always, day, week, month)
      end
    end

    ##
    # Error class raised when {Config#generate_html} is invalid
    #
    class GenerateHtmlError < ConfigError
      def initialize
        super %('generate_html' must be one of: true, false)
      end
    end

    ##
    # todo
    #
    class UpdatedOnError < ConfigError
      def initialize
        super %(todo)
      end
    end

    ############################################################################

    ##
    # Error class raised when the scraping of a site's user list
    # returns invalid data
    #
    class ScrapeError < Error
      #
      # The name of the site that produced the error
      attr_reader :site_name

      def initialize(site_name, msg = nil)
        @site_name = site_name
        super msg || message
      end
    end

    ##
    # Error class raised when a site scrape returns an empty array
    #
    class NoUsersFoundError < ScrapeError

      # (see Tildeverse::Error#message)
      def message
        %(No users found for site: #{site_name})
      end

      # (see Tildeverse::Error#console_message)
      def console_message
        <<~MSG + developer_issue
          ERROR: No users found for site:
                   "#{site_name}"
                 The URL is online and accessible, but the code
                 to scrape the list of users needs updating.
        MSG
      end
    end
  end
end
