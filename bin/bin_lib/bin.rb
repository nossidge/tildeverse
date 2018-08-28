#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

module Tildeverse
  ##
  # Define the commands that are possible through the CLI
  #
  class Bin
    attr_reader :argv_orig, :argv, :options

    ##
    # The parameter should be an Array in the same format as the ARGV variable.
    # This will then be parsed to determine the 'options' hash.
    # Alternatively (mostly for testing purposes) a Hash can be given.
    # This will be used directly as the 'options' hash.
    #
    # @param [Array<String>, Hash] argv
    #
    def initialize(argv = [])
      case argv
      when Array
        parse(argv)
      when Hash
        @options = argv
      end
    end

    ##
    # Use the arguments to decide which function to perform
    #
    def run
      case argv[0]
      when 'help'
        puts tildeverse_help
      when 'version'
        puts tildeverse_version
      when 'scrape'
        tildeverse_scrape
      when 'fetch'
        tildeverse_fetch
      when 'new'
        tildeverse_new
      when 'json'
        tildeverse_json
      when 'sites'
        tildeverse_sites(argv[1])
      when 's', 'site'
        tildeverse_site(argv[1])
      when 'u', 'user', 'users'
        tildeverse_users(argv[1])
      else
        tildeverse_users(argv[0])
      end
    end

    ##
    # $ tildeverse help
    #
    # Display help info
    #
    def tildeverse_help
      <<-HELP.gsub(/^ {8}/, '')
          Tildeverse: List of tilde-sites and their users
          https://github.com/nossidge/tildeverse
          Version #{Tildeverse.version_number} - #{Tildeverse.version_date}

          Usage: tildeverse <command> [regex] [options]

        $ tildeverse scrape
          Scrape the user list of each box, and generate the JSON files

        $ tildeverse fetch
          Fetch data from #{Files.remote_json.sub(%r{.*//}, '')}

        $ tildeverse new
          See if there have been any additions by ~pfhawkins

        $ tildeverse json [-p]
          Write the full JSON file to standard out

        $ tildeverse sites [regex] [-l] [-j -p]
          List all online sites in the Tildeverse
          'regex' argument filters URLs by regex

        $ tildeverse site [regex] [-l] [-j -p]
          List all users for the specified Tildebox
          'regex' argument filters URLs by regex

        $ tildeverse user [regex] [-l] [-j -p]
          or
        $ tildeverse [regex] [-l] [-j -p]
          List all the users by URL
          'regex' argument filters URLs by regex

        [options]
          -l  output in long listing format
          -j  output in JSON format
          -p  output in pretty JSON format
      HELP
    end

    ##
    # $ tildeverse version
    #
    # Display version info
    #
    def tildeverse_version
      number = Tildeverse.version_number
      date   = Tildeverse.version_date
      "tildeverse #{number} (#{date})"
    end

    ##
    # $ tildeverse scrape
    #
    # Scrape the user list of each box, and generate the JSON files
    #
    def tildeverse_scrape
      Tildeverse.scrape
    end

    ##
    # $ tildeverse fetch
    #
    # Fetch data from tilde.town/~nossidge/tildeverse/tildeverse.json
    #
    def tildeverse_fetch
      Tildeverse.fetch
    end

    ##
    # $ tildeverse new
    #
    # See if there have been any additions by ~pfhawkins
    #
    def tildeverse_new
      Tildeverse::PFHawkins.new.puts_if_new
    end

    ##
    # $ tildeverse json [-p]
    #
    # Write the JSON file to standard out
    # -p switch will output in pretty format
    #
    def tildeverse_json
      obj = Tildeverse.data.serialize.for_tildeverse_json
      to_stdout options[:pretty] ? JSON.pretty_generate(obj) : obj.to_json
    end

    ##
    # $ tildeverse sites [regex] [-l] [-j -p]
    #
    # List all online sites in the Tildeverse
    # 'regex' argument filters site URLs by regex
    #
    def tildeverse_sites(regex)
      sites = Tildeverse.sites.select(&:online?)
      sites.select! { |i| i.uri.root[Regexp.new(regex)] } if regex
      to_stdout format_sites(sites) { sites.map(&:name) }
    end

    ##
    # $ tildeverse site [regex] [-l] [-j -p]
    #
    # List all users for the specified Tildebox
    # 'regex' argument filters site URLs by regex
    #
    def tildeverse_site(regex)
      sites = Tildeverse.sites.select(&:online?)
      sites.select! { |i| i.uri.root[Regexp.new(regex)] } if regex
      users = sites.map(&:users).flatten
      to_stdout format_users(users) { users.map(&:name) }
    end

    ##
    # $ tildeverse user [regex] [-l] [-j -p]
    #   or
    # $ tildeverse [regex] [-l] [-j -p]
    #
    # List all the users by URL
    # 'regex' argument filters user URLs by regex
    #
    def tildeverse_users(regex)
      users = Tildeverse.users
      users.select! { |i| i.homepage[Regexp.new(regex)] } if regex
      to_stdout format_users(users) { users.map(&:homepage) }
    end

    private

    ##
    # Parse the arguments and set the values of
    # {#options}, {#argv_orig}, and {#argv}
    #
    # @return [Array<String>] remaining arguments
    #
    def parse(args)
      @options = {}
      @argv_orig = args.dup
      @argv = OptionParser.new do |opts|
        opts.on('-l', '--long')    { @options[:long]   = true }
        opts.on('-j', '--json')    { @options[:json]   = true }
        opts.on('-p', '--pretty')  { @options[:pretty] = true }
        opts.on('-h', '--help')    { puts tildeverse_help;    exit }
        opts.on('-v', '--version') { puts tildeverse_version; exit }
      end.parse(args)
    end

    ##
    # Output a list of users in a consistant way
    #
    # @param [Array<User>] users
    # @param [Hash] options
    # @yield a default value, if no 'options' specifications are met
    # @return [String] text to be put to stdout
    #
    def format_users(users)
      if options[:long]
        Tildeverse.data.serialize.users_as_wsv(users)

      elsif options[:json] || options[:pretty]
        obj = Tildeverse.data.serialize.users(users)
        options[:pretty] ? JSON.pretty_generate(obj) : obj.to_json

      else
        yield
      end
    end

    ##
    # Output a list of sites in a consistant way
    #
    # @param [Array<Site>] sites
    # @param [Hash] options
    # @yield a default value, if no 'options' specifications are met
    # @return [String] text to be put to stdout
    #
    def format_sites(sites)
      if options[:long]
        Tildeverse.data.serialize.sites_as_wsv(sites)

      elsif options[:json] || options[:pretty]
        obj = Tildeverse.data.serialize.sites(sites)
        options[:pretty] ? JSON.pretty_generate(obj) : obj.to_json

      else
        yield
      end
    end

    ##
    # Output a string to console. I had a weird bug that caused output to
    # error when piped to another command on MinGW. Using 'rescue' fixed it.
    #
    # @param [String] string to output
    #
    def to_stdout(output)
      puts output
    rescue StandardError
      nil
    end
  end
end
