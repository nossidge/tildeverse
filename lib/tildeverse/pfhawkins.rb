#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # ~pfhawkins@tilde.club maintains a JSON list of all other tilde servers.
  #
  # http://tilde.club/~pfhawkins/othertildes.html
  #
  # If this has been updated let me know. Then I can manually add the new box.
  #
  class PFHawkins
    ##
    # @return [Array<String>] the Tilde servers that we know about
    #
    SERVER_LIST = %w[
      ctrl-c.club
      cybyte.club
      hackers.cool
      nand.club
      pebble.ink
      protocol.club
      remotes.club
      riotgirl.club
      rudimentarylathe.org
      skylab.org
      squiggle.city
      thunix.org
      tilde.team
      tilde.town
      tilde.works
      yourtilde.com
    ].freeze

    ##
    # @return [String] URL of the remote HTML list of Tilde servers
    #
    URL_HTML = 'http://tilde.club/~pfhawkins/othertildes.html'

    ##
    # @return [String] URL of the remote JSON list of Tilde servers
    #
    URL_JSON = 'http://tilde.club/~pfhawkins/othertildes.json'

    ##
    # @return [Array<String>] the Tilde servers scraped from ~pfhawkins
    # @example
    #   [
    #     'ctrl-c.club',
    #     'hackers.cool',
    #     'skylab.org',
    #     'perispomeni.club',
    #     'tilde.team',
    #     'yourtilde.com'
    #   ]
    #
    def servers
      @servers ||= json.values.map do |i|
        URI(i).host.sub('www.', '')
      end.sort
    end
    alias sites servers
    alias boxes servers

    ##
    # @return [Boolean] whether there is a new server on the ~pfhawkins list
    #
    def new?
      a = servers
      b = SERVER_LIST
      !(a - b | b - a).empty?
    end

    ##
    # Output a message (using puts) if there is a new server
    #
    def puts_if_new
      puts new_message if new?
    end

    private

    ##
    # Fetch and return the remote JSON list of Tilde servers
    #
    # @return [Hash]
    #
    def json
      @json ||= JSON[open(URL_JSON).read]
    end

    ##
    # @return [String] message to output if there is a new server
    #
    def new_message
      "-- New Tilde Boxes!\n" + URL_HTML
    end
  end
end
