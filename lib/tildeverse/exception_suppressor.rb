#!/usr/bin/env ruby
# frozen_string_literal: true

require 'delegate'

module Tildeverse
  ##
  # Suppress one or more exception classes, and carry on with processing.
  # This is only appropriate for errors which can be safely ignored.
  # Currently (and probably only ever) valid with {Error::OfflineURIError}
  #
  # This class is a SimpleDelegator for an Array object, which is used to
  # store those exceptions that should be suppressed
  #
  class ExceptionSuppressor < SimpleDelegator
    ##
    # @param [Array<Exception>] exceptions
    #   Exception list to store in delegated self array
    #
    def initialize(*exceptions)
      super [*exceptions]
    end

    ##
    # Handle the possibly-suppressible exception. If the given exception
    # is contained within the +self+ array, then it will be suppressed,
    # otherwise it will be raised as usual
    #
    # @param [Exception] exception
    #   exception to suppress
    # @yield
    #   code that could raise an exception
    #
    def handle(exception)
      if include?(exception)
        begin
          yield
        rescue exception
        end
      else
        yield
      end
    end
  end
end
