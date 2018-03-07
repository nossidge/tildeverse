#!/usr/bin/env ruby

module Tildeverse
  #
  # ~pfhawkins JSON list of all other tildes.
  # If this has been updated let me know. Then I can manually add the new box.
  class PFHawkins
    def html_url
      'http://tilde.club/~pfhawkins/othertildes.html'
    end

    def json_url
      'http://tilde.club/~pfhawkins/othertildes.json'
    end

    def json
      return @json if @json
      @json = JSON[open(json_url).read]
    end

    def boxes
      return @boxes if @boxes
      @boxes = json.values.map do |i|
        i = i[0...-1] if i[-1] == '/'
        i.split('//').last
      end
    end
    alias sites boxes

    def new?
      boxes.length != 19
    end

    def puts_if_new
      puts new_message if new?
    end

    private

    def new_message
      "-- New Tilde Boxes!\n" + html_url
    end
  end
end
