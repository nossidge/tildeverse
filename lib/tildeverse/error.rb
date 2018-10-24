#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Namespace module for the Tildeverse exception hierarchy
  #
  # All exceptions are descendants of class {Tildeverse::Error::Error}
  #
  # All errors should have short messages
  # {Tildeverse::Error::Error#message}
  # for developers using the gem, and longer messages
  # {Tildeverse::Error::Error#console_message}
  # for end users who will be using the bin through the console
  #
  # If accessing through a console, all these errors are cause to exit
  #
  module Error
    ##
    # Class to inherit for all Tildeverse exception classes
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

      private

      # Message to append to console output if the error is all my fault
      def developer_error
        <<-MSG.gsub(/^ {10}/, '')
                 Developer error! You should not be seeing this!
                 I'd be very grateful if you'd log this issue at:
                 https://github.com/nossidge/tildeverse/issues
                 Thanks,
                   ~nossidge
        MSG
      end
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
      #
      # (see Tildeverse::Error::Error#message)
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

      # (see Tildeverse::Error::Error#console_message)
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

      # (see Tildeverse::Error::Error#console_message)
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
    # Exception to raise on invalid URI input
    #
    class NotHTTPError < Error
      #
      # Invalid URI that was attempted
      attr_reader :uri

      def initialize(uri)
        @uri = uri
        super message
      end

      # (see Tildeverse::Error::Error#message)
      def message
        %(Tilde URI must be HTTP or HTTPS: "#{uri}")
      end

      # (see Tildeverse::Error::Error#console_message)
      def console_message
        <<~MSG + developer_error
          ERROR: Invalid URL encounted for Tilde site:
                   "#{uri}"
        MSG
      end
    end
  end
end
