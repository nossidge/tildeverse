#!/usr/bin/env ruby

describe 'Tildeverse::DataSerializerClass' do

  # Same info as Config class, but not tied to a file on the system.
  let(:config_struct) do
    Struct.new(
      :update_type,
      :update_frequency,
      :generate_html,
      :updated_on
    ) do
      def generate_html?; generate_html; end
      def update; nil; end
    end
  end

  let(:config) do
    config_struct.new('scrape', 'week', false, '2018-06-08')
  end

  let(:instance) do
    Tildeverse::Data.new(config)
  end

  ##############################################################################

  it '#serialize_users(users)' do
    data = instance
    serializer = Tildeverse::DataSerializerClass.new(data)
    %w[nossidge imt foo].each do |username|
      users = data.user(username)
      hash = serializer.serialize_users(users)
      users.each do |user_obj|
        sitename = user_obj.site.name
        %i[tagged tags time].each do |i|
          expect(hash.dig(sitename, username, i)).to_not be nil
        end
      end
    end
  end

  it '#serialize_sites' do
    data = instance
    serializer = Tildeverse::DataSerializerClass.new(data)
    %w[pebble.ink tilde.town].each do |sitename|
      sites = data.site(sitename)
      hash = serializer.serialize_sites(sites)
      %i[url_root url_list url_format_user online user_count users].each do |i|
        expect(hash.dig(sitename, i)).to_not be nil
      end
    end
  end

  it '#serialize_tildeverse_json' do
    data = instance
    serializer = Tildeverse::DataSerializerClass.new(data)
    hash = serializer.serialize_tildeverse_json
    expect(hash[:metadata]).to_not be nil
    %i[url date_human date_unix date_timezone].each do |i|
      expect(hash.dig(:metadata, i)).to_not be nil
    end
    expect(hash[:sites]).to eq serializer.serialize_all_sites
  end

  it '#serialize_users_json' do
    data = instance
    serializer = Tildeverse::DataSerializerClass.new(data)
    hash = serializer.serialize_users_json
    hash.each do |site, site_hash|
      expect(site).to be_a String
      site_hash.each do |user_name, user_url|
        expect(user_name).to be_a String
        expect(user_url).to be_a String
      end
    end
  end
end
