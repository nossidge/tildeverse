#!/usr/bin/env ruby

################################################################################

require_relative 'tildeverse'

################################################################################

# http://guides.railsgirls.com/sinatra-app
require 'sinatra'
require 'erb'

# This is probably overkill...
Rack::Utils.key_space_limit = 2**62

# Log output to the terminal.
use Rack::Logger

################################################################################

# Update user tags from INPUT to OUTPUT.
# (Without doing the full site-scrape)
def update_tags
  output = Tildeverse::Config.output_tildeverse

  Tildeverse::Config.input_tildeverse['sites'].each do |site, site_hash|
    [*site_hash['users']].each do |user, user_hash|
      begin
        output['sites'][site]['users'][user]['tagged'] = user_hash['tagged']
        output['sites'][site]['users'][user]['tags']   = user_hash['tags']
      rescue StandardError
      end
    end
  end

  File.open(Tildeverse::Config.output_json_tildeverse, 'w') do |f|
    f.write JSON.pretty_generate(output).force_encoding('UTF-8')
  end
end

################################################################################

class TildeTagApp < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  # Home page, index.html
  get '/' do
    @tags = %w[
      empty brief redirect links blog
      poetry prose art photo audio video gaming
      tutorial app code procgen web1.0 unix tilde ]
    erb :index
  end

  # This is given to the client as an Xreq.
  get '/tildeverse.json' do
    File.read(Tildeverse::Config.output_json_tildeverse)
  end

  # Save the tags to the JSON file.
  post '/save_tags' do
    request.body.rewind
    input_data = JSON[request.body.read]
    json = Tildeverse::Config.input_tildeverse

    # Alter the original JSON, to update with new tags.
    input_data.each do |site, users|
      json['sites'][site] ||= {}
      json['sites'][site]['users'] ||= {}
      users.each do |user, tags|

        # Delete from the original hash if [*tags] is empty.
        if [*tags].empty?
          json['sites'][site]['users'].delete(user)
        else
          date_now = Time.now.strftime('%Y-%m-%d')
          json['sites'][site]['users'][user] ||= {}
          json['sites'][site]['users'][user]['tagged'] = date_now
          json['sites'][site]['users'][user]['tags'] = tags
        end
      end
    end

    # Sort the site, user names, and tags.
    # ToDo: Is there a better way of doing this?
    json['sites'] = json['sites'].sort.to_h
    json['sites'].each do |site, site_hash|
      if json['sites'][site]['users']
        json['sites'][site]['users'] =
          json['sites'][site]['users'].sort.to_h
        json['sites'][site]['users'].each do |user, user_hash|
          json['sites'][site]['users'][user] =
            json['sites'][site]['users'][user].sort.to_h
          if json['sites'][site]['users'][user]['tags']
            json['sites'][site]['users'][user]['tags'] =
              json['sites'][site]['users'][user]['tags'].sort
          end
        end
      end
    end

    # Write the hash to both JSON files.
    File.open(Tildeverse::Config.input_json_tildeverse, 'w') do |f|
      f.write JSON.pretty_generate(json)
      f.write "\n"
    end
    update_tags

    # Output some user messages to the console.
    num = input_data.keys.inject(0) do |sum, i|
      sum += input_data[i].keys.count
    end
    logger.info "#{num} users updated"
    logger.info input_data
  end

end

################################################################################

def start_server
  update_tags
  TildeTagApp.run!
end

################################################################################
