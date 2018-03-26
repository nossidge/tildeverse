#!/usr/bin/env ruby

module Tildeverse
  ##
  # ~pfhawkins@tilde.club maintains a JSON list of all other tilde servers.
  #
  # http://tilde.club/~pfhawkins/othertildes.html
  #
  # If this has been updated let me know. Then I can manually add the new box.
  class PFHawkins
    ##
    # URL of the remote HTML list of Tilde servers.
    # @return [String]
    # @example
    #   'http://tilde.club/~pfhawkins/othertildes.html'
    #
    def url_html
      'http://tilde.club/~pfhawkins/othertildes.html'
    end

    ##
    # URL of the remote JSON list of Tilde servers.
    # @return [String]
    # @example
    #   'http://tilde.club/~pfhawkins/othertildes.json'
    #
    def url_json
      'http://tilde.club/~pfhawkins/othertildes.json'
    end

    ##
    # Array of all the Tilde servers on the list.
    # @return [Array<String>]
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
      return @servers if @servers
      @servers = json.values.map do |i|
        i = i[0...-1] if i[-1] == '/'
        i.split('//').last
      end
    end
    alias sites servers
    alias boxes servers

    ##
    # Hard-coded count of the last verified number of expected boxes.
    # @return [Integer]
    # @example
    #   19
    #
    def count
      19
    end

    ##
    # If there is there a new server on the ~pfhawkins list.
    # @return [Boolean]
    #
    def new?
      servers.length != count
    end

    ##
    # Output a message (using puts) if there is a new server.
    # @return [nil]
    #
    def puts_if_new
      puts new_message if new?
    end

    private

    ##
    # Fetch and return the remote JSON list of Tilde servers.
    # @return [Hash]
    #
    def json
      return @json if @json
      @json = JSON[open(url_json).read]
    end

    ##
    # Message to output if there is a new server.
    # @return [String]
    #
    def new_message
      "-- New Tilde Boxes!\n" + url_html
    end
  end
end
