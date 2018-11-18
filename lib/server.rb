#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'tildeverse'

require 'sinatra'
require 'erb'

# This is probably overkill...
Rack::Utils.key_space_limit = 2**62

# Log output to the terminal.
use Rack::Logger

# Make sure the JSON files are up-to-date.
Tildeverse.save

################################################################################

module Tildeverse
  ##
  # Browser-based GUI to help with the tagging of user sites.
  #
  class App < Sinatra::Base
    set :root,          Files.dir_root + 'web'
    set :views,         Files.dir_root + 'web/views'
    set :public_folder, Files.dir_root + 'web/public'

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
    get '/?' do
      erb :index
    end

    ##
    # @method get_browser
    # @overload GET '/browser/?'
    #
    # Page for the user tag browsing app.
    #
    get '/browser/?' do
      redirect '/browser/index.html'
    end

    ##
    # @method get_tagging
    # @overload GET '/tagging/?'
    #
    # Page for the user tagging app.
    #
    get '/tagging/?' do
      erb :tagging
    end

    ##
    # @method get_tildeverse_json
    # @overload GET '/tildeverse.json'
    #
    # This is given to the client as an Xreq.
    #
    get '/tildeverse.json' do
      Tildeverse.data.serialize.for_tildeverse_json.to_json
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
          next if tags.empty?
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
