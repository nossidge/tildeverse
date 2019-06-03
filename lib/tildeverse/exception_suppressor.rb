#!/usr/bin/env ruby
# frozen_string_literal: true

require 'delegate'

module Tildeverse
  ##
  # Suppress one or more exception classes, and carry on with processing.
  # This is only appropriate for errors which can be safely ignored.
  # Currently (and probably only ever) valid with {Error::OfflineURIError}
  # and {Error::ScrapeError}
  #
  # This class is a SimpleDelegator for an Array object, which is used to
  # store those exceptions that should be suppressed
  #
  # @example
  #   suppressor = Tildeverse::ExceptionSuppressor.new
  #   suppressor << ZeroDivisionError
  #   suppressor.handle(ZeroDivisionError) { 1 / 0 }
  #   puts 'error not raised; this line will be printed'
  #
  # @example
  #   suppressor = Tildeverse::ExceptionSuppressor.new
  #   suppressor << Errno::ENOENT
  #   suppressor.handle(ZeroDivisionError) { 1 / 0 }
  #   puts 'error raised above; this line will never be reached'
  #
  class ExceptionSuppressor < SimpleDelegator
    ##
    # Creates a new {ExceptionSuppressor}, with an optional initial array of
    # exceptions
    #
    # @example
    #   ExceptionSuppressor.new(Error::OfflineURIError)
    #   ExceptionSuppressor.new(ZeroDivisionError, IOError, Errno::ENOENT)
    #
    # @param [Array<Exception>] exceptions
    #   Exception list to store in delegated +self+ array
    #
    def initialize(*exceptions)
      super [*exceptions]
    end

    ##
    # Handle the possibly-suppressible exception. If the given exception
    # is contained within the +self+ array, then it will be suppressed,
    # otherwise it will be raised as usual
    #
    # @example
    #   suppressor = Tildeverse::ExceptionSuppressor.new(ZeroDivisionError)
    #   suppressor.handle(ZeroDivisionError) { 1 / 0 }
    #   puts 'error not raised; this line will be printed'
    #
    # @example
    #   suppressor = Tildeverse::ExceptionSuppressor.new(Errno::ENOENT)
    #   suppressor.handle(ZeroDivisionError) { 1 / 0 }
    #   puts 'error raised above; this line will never be reached'
    #
    # @param [Exception] exception
    #   exception to suppress
    # @yield
    #   code that could raise an exception
    # @return
    #   result of the yielded block, or nil if an exception was suppressed
    #
    def handle(exception)
      if include?(exception)
        # rubocop:disable Lint/HandleExceptions
        begin
          yield
        rescue exception
        end
        # rubocop:enable Lint/HandleExceptions
      else
        yield
      end
    end
  end
end
