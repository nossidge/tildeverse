#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################

require_relative 'tildeverse.rb'

################################################################################

# http://guides.railsgirls.com/sinatra-app
require 'sinatra'
require 'erb'

# This is probably overkill...
Rack::Utils.key_space_limit = 2**62

################################################################################

# Update user tags from INPUT to OUTPUT.
# (Without doing the full site-scrape)
def update_tags
  input = JSON[File.read(INPUT_JSON_TILDEVERSE,
    :external_encoding => 'utf-8',
    :internal_encoding => 'utf-8'
  )]
  output = JSON[File.read(OUTPUT_JSON_TILDEVERSE,
    :external_encoding => 'utf-8',
    :internal_encoding => 'utf-8'
  )]

  input['sites'].each do |site, site_hash|
    [*site_hash['users']].each do |user, user_hash|
      output['sites'][site]['users'][user]['tagged'] = user_hash['tagged']
      output['sites'][site]['users'][user]['tags']   = user_hash['tags']
    end
  end

  File.open(OUTPUT_JSON_TILDEVERSE, 'w') do |f|
    f.write JSON.pretty_generate(output).force_encoding('UTF-8')
  end
end

################################################################################

class TildeTagApp < Sinatra::Base

  # Home page, index.html
  get '/' do
    @tags = %w[
      empty TODO brief redirect links blog poetry prose art photo
      audio video gaming tutorial code procgen web1.0 unix tilde]
    erb :index
  end

  # This is given to the client as an Xreq.
  get '/tildeverse.json' do
    File.read(OUTPUT_JSON_TILDEVERSE)
  end

  # Save the tags to the JSON file.
  post '/save_tags' do
    request.body.rewind
    input_data = JSON[request.body.read]
    json = JSON[File.read(INPUT_JSON_TILDEVERSE,
      :external_encoding => 'utf-8',
      :internal_encoding => 'utf-8'
    )]

    # Alter the original JSON, to update with new tags.
    input_data.each do |site, users|
      json['sites'][site] ||= {}
      json['sites'][site]['users'] ||= {}
      users.each do |user, tags|

        # Delete from the original hash if [*tags] is empty.
        if [*tags].empty?
          json['sites'][site]['users'].delete(user)
        else
          date_now = Time.now.strftime("%Y-%m-%d")
          json['sites'][site]['users'][user] ||= {}
          json['sites'][site]['users'][user]['tagged'] = date_now
          json['sites'][site]['users'][user]['tags'] = tags
        end
      end
    end

    # Sort the site and user names.
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
    File.open(INPUT_JSON_TILDEVERSE, 'w') do |f|
      f.write JSON.pretty_generate(json)
      f.write "\n"
    end
    update_tags

    # Output some user messages to the console.
    num = input_data.keys.inject(0) do |sum, i|
      sum += input_data[i].keys.count
    end
    puts "#{num} users updated"
    puts input_data
  end

end

################################################################################

def start_server
  update_tags
  TildeTagApp.run!
end

################################################################################
