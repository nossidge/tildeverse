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
      when Hash
        @options = argv
      else # assume Array
        parse([*argv])
      end
      apply_options
    end

    ##
    # Use {#options} hash to set internal Tildeverse state
    #
    def apply_options
      if options[:force]
        Tildeverse.suppress << Error::OfflineURIError
      end
    end

    ############################################################################

    ##
    # Use the arguments to decide which function to perform
    #
    def run
      command = argv[0]
      case
      when %w[get].include?(command) && authorised?
        tildeverse_get
      when %w[scrape].include?(command) && authorised?
        tildeverse_scrape
      when %w[fetch].include?(command) && authorised?
        tildeverse_fetch
      when %w[new].include?(command)
        tildeverse_new
      when %w[json].include?(command)
        tildeverse_json
      when %w[s site sites].include?(command)
        tildeverse_sites
      when %w[u user users].include?(command)
        tildeverse_users
      else
        tildeverse_users
      end
    end

    ############################################################################

    ##
    # $ tildeverse get
    #
    # Get data from remote servers.
    # Use the config setting to choose between 'scrape' and 'fetch'
    #
    def tildeverse_get
      Tildeverse.get
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
      puts options[:pretty] ? JSON.pretty_generate(obj) : obj.to_json
    end

    ##
    # $ tildeverse sites [-l] [-j/p] [-o] [-u/s/t 'regex']
    #
    # List all sites in the Tildeverse
    #
    def tildeverse_sites
      sites = filtered_users.map(&:site).uniq
      puts format_sites(sites) { sites.map(&:name) }
    end

    ##
    # $ tildeverse users [-l] [-j/p] [-o] [-u/s/t 'regex']
    #   or
    # $ tildeverse [-l] [-j/p] [-o] [-u/s/t 'regex']
    #
    # List all the users by URL
    #
    def tildeverse_users
      users = filtered_users
      puts format_users(users) { users.map(&:homepage) }
    end

    ############################################################################

    private

    ##
    # Return the console help info. If the current system user is not
    # authorised for write access, the options 'get, scrape, fetch' will
    # not be shown
    #
    # @return [String] help info
    #
    def help_text
      main_doc = <<~HELP
          Tildeverse: List of tilde-sites and their users
          https://github.com/nossidge/tildeverse
          Version: #{Tildeverse.version_number} (#{Tildeverse.version_date})

          Usage: tildeverse <command> [options]

        @authorised_commands@

        $ tildeverse new
          See if there have been any additions by ~pfhawkins

        $ tildeverse json [-p]
          Write the full JSON file to standard out

        $ tildeverse sites [-l] [-j/p] [-o] [-u/s/t 'regex']
          List sites in the Tildeverse

        $ tildeverse users [-l] [-j/p] [-o] [-u/s/t 'regex']
          or
        $ tildeverse [-l] [-j/p] [-o] [-u/s/t 'regex']
          List users in the Tildeverse

          Options:
      HELP

      authorised_commands = <<~HELP
        $ tildeverse get [-f]
          Get data from remote servers, using config options
          Set config 'update_type' to choose download type
          Set config 'update_frequency' to avoid repeated download

        $ tildeverse scrape [-f]
          Scrape the user list of each box, and save to file

        $ tildeverse fetch [-f]
          Fetch data from #{Files.remote_json.sub(%r{.*//}, '')}
      HELP

      output = main_doc.dup
      if authorised?
        output.sub!("@authorised_commands@\n", authorised_commands)
      else
        output.sub!("\n@authorised_commands@\n", '')
      end
    end

    ##
    # @return [String] version info
    #
    def version_text
      number = Tildeverse.version_number
      date   = Tildeverse.version_date
      "tildeverse #{number} (#{date})"
    end

    ############################################################################

    ##
    # Parse the arguments and set the values of
    # {#options}, {#argv_orig}, and {#argv}
    #
    # @return [Array<String>] remaining arguments
    #
    def parse(args)
      @options = {}
      @argv_orig = args.dup

      # Parse the options and show errors on failure
      begin
        @argv = option_parser.parse(args)
      rescue OptionParser::ParseError => e
        puts e
        exit 1
      end
    end

    ##
    # @return [OptionParser]
    #
    def option_parser
      OptionParser.new do |opts|
        opts.banner = help_text

        # Regex filter options
        opts.on('-u', '--user STRING', 'Regex to include users') do |s|
          @options[:user] = s
        end
        opts.on('-s', '--site STRING', 'Regex to include sites') do |s|
          @options[:site] = s
        end
        opts.on('-t', '--tag STRING', 'Regex to include tags') do |s|
          @options[:tag] = s
        end
        opts.on('-U', '--xuser STRING', 'Regex to exclude users') do |s|
          @options[:xuser] = s
        end
        opts.on('-S', '--xsite STRING', 'Regex to exclude sites') do |s|
          @options[:xsite] = s
        end
        opts.on('-T', '--xtag STRING', 'Regex to exclude tags') do |s|
          @options[:xtag] = s
        end

        opts.separator nil

        # Boolean filter options
        opts.on('-o', '--offline', 'Include offline users') do
          @options[:offline] = true
        end
        opts.on('-h', '--http', 'Only include sites using http') do
          @options[:http] = true
        end
        opts.on('-H', '--https', 'Only include sites using https') do
          @options[:https] = true
        end

        opts.separator nil

        # Output options
        opts.on('-l', '--long', 'Output in long listing format') do
          @options[:long] = true
        end
        opts.on('-j', '--json', 'Output in JSON format') do
          @options[:json] = true
        end
        opts.on('-p', '--pretty', 'Output in pretty JSON format') do
          @options[:pretty] = true
        end

        opts.separator nil

        # Exception handling
        opts.on('-f', '--force', 'Force continuation on error') do
          @options[:force] = true
        end

        opts.separator nil

        # Help output
        opts.on('--help', 'Display this help screen') do
          puts opts
          exit 0
        end
        opts.on('--version', 'Display the version number') do
          puts version_text
          exit 0
        end
      end
    end

    ############################################################################

    ##
    # Return the complete user list filtered according to the {options} flags
    #
    # @return [Array<User>]
    #
    def filtered_users
      Tildeverse.data.users.dup.tap do |users|
        filter_by_online!(users)
        filter_by_hypertext_protocol!(users)
        filter_by_user!(users)
        filter_by_site!(users)
        filter_by_tag!(users)
        filter_by_user_exclude!(users)
        filter_by_site_exclude!(users)
        filter_by_tag_exclude!(users)
      end
    end

    def filter_by_online!(users)
      users.select!(&:online?) unless options[:offline]
    end

    def filter_by_hypertext_protocol!(users)
      return users unless options[:http] ^ options[:https]
      protocol = options[:http] ? 'http' : 'https'
      users.select! { |u| u.site.uri.scheme == protocol }
    end

    def filter_by_user!(users)
      regex = options[:user]
      return users unless regex
      users.select! { |u| u.name[Regexp.new(regex)] }
    end

    def filter_by_site!(users)
      regex = options[:site]
      return users unless regex
      users.select! { |u| u.site.name[Regexp.new(regex)] }
    end

    def filter_by_tag!(users)
      regex = options[:tag]
      return users unless regex
      users.select! { |u| !u.tags.grep(Regexp.new(regex)).empty? }
    end

    def filter_by_user_exclude!(users)
      regex = options[:xuser]
      return users unless regex
      users.reject! { |u| u.name[Regexp.new(regex)] }
    end

    def filter_by_site_exclude!(users)
      regex = options[:xsite]
      return users unless regex
      users.reject! { |u| u.site.name[Regexp.new(regex)] }
    end

    def filter_by_tag_exclude!(users)
      regex = options[:xtag]
      return users unless regex
      users.select! { |u| u.tags.grep(Regexp.new(regex)).empty? }
    end

    ############################################################################

    ##
    # Output a list of users in a consistant way
    #
    # @param [Array<User>] users
    # @yield a default value, if no {#options} specifications are met
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
    # @yield a default value, if no {#options} specifications are met
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

    ############################################################################

    ##
    # Is the logged-in user authorised to alter data?
    # We'll hide the potentially destructive commands if not
    #
    # @return [Boolean]
    #
    def authorised?
      Tildeverse.config.authorised?
    end

    ##
    # Output a string to console. I had a weird bug that caused output to
    # error when piped to another command on MinGW. Using 'rescue' fixed it.
    #
    # @param [String] string to output
    #
    def puts(output)
      super output
    rescue StandardError
      nil
    end
  end
end
