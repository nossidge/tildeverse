#!/usr/bin/env ruby

require_relative 'tildeverse'

require 'sinatra'
require 'erb'

# This is probably overkill...
Rack::Utils.key_space_limit = 2**62

# Log output to the terminal.
use Rack::Logger

################################################################################

module Tildeverse
  ##
  # Browser-based GUI to help with the tagging of user sites.
  #
  class App < Sinatra::Base
    configure :production, :development do
      enable :logging
    end

    ##
    # Run the app from a server on localhost.
    #
    def run!
      super
    end

    ##
    # @method get_index
    # @overload GET '/'
    #
    # Home page, index.html
    #
    get '/' do
      @tags = %w[
        empty brief redirect links blog
        poetry prose art photo audio video gaming
        tutorial app code procgen web1.0 unix tilde
      ]
      erb :index
    end

    ##
    # @method get_tildeverse_json
    # @overload GET '/tildeverse.json'
    #
    # This is given to the client as an Xreq.
    #
    get '/tildeverse.json' do
      serializer = DataSerializer.new(Tildeverse.data)
      serializer.serialize_tildeverse_json.to_json
    end

    ##
    # @method post_save_tags
    # @overload POST '/save_tags'
    #
    # Save the tags to the JSON file.
    #
    post '/save_tags' do
      #
      # Update the tags of all the affected users.
      req = JSON[request.body.read]
      req.each do |site_name, user_hash|
        user_hash.each do |user_name, tags|
          user = Tildeverse.site(site_name).user(user_name)
          user.tags = tags
        end
      end

      # Save the state to file.
      Tildeverse.save

      # Output some user messages to the console.
      num = req.keys.inject(0) do |sum, i|
        sum + req[i].keys.count
      end
      logger.info "#{num} users updated:"
      logger.info req
    end
  end
end
