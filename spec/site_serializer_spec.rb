#!/usr/bin/env ruby

describe 'Tildeverse::SiteSerializer' do
  valid_params = {
    name: 'example.com',
    url_root: 'http://www.example.com',
    url_list: 'http://www.example.com/userlist.json',
    homepage_format: 'http://www.example.com/~USER/'
  }

  describe '#for_tildeverse_json' do
    class SiteImplementingAllMethods < Tildeverse::Site
      def scrape_users; 'foo'; end
      def online?; 'foo'; end
    end

    it 'should return correct header if no users' do
      site = SiteImplementingAllMethods.new(valid_params)
      serializer = Tildeverse::SiteSerializer.new(site)
      hash = serializer.for_tildeverse_json
      expect(hash).to be_a Hash
      keys = %i[url_root url_list url_format_user online user_count users]
      expect(hash.keys).to eq keys
      expect(hash[:url_root]).to eq valid_params[:url_root]
      expect(hash[:url_list]).to eq valid_params[:url_list]
      expect(hash[:url_format_user]).to eq valid_params[:homepage_format]
      expect(hash[:online]).to eq site.online?
      expect(hash[:users]).to be_a Hash
      expect(hash[:users].keys.count).to eq hash[:user_count]
      expect(hash[:user_count]).to eq site.users.select(&:online?).count
    end

    it 'should return full data if online users present' do
      params = valid_params.dup
      params[:name] = 'pebble.ink'
      site = SiteImplementingAllMethods.new(params)
      serializer = Tildeverse::SiteSerializer.new(site)
      hash = serializer.for_tildeverse_json
      expect(hash).to be_a Hash
      keys = %i[url_root url_list url_format_user online user_count users]
      expect(hash.keys).to eq keys
      expect(hash[:url_root]).to eq params[:url_root]
      expect(hash[:url_list]).to eq params[:url_list]
      expect(hash[:url_format_user]).to eq params[:homepage_format]
      expect(hash[:online]).to eq site.online?
      expect(hash[:users]).to be_a Hash
      expect(hash[:users].keys.count).to eq hash[:user_count]
      expect(hash[:user_count]).to eq site.users.select(&:online?).count
      hash[:users].each do |user_name, user_hash|
        expect(user_name).to be_a String
        expect(user_hash).to be_a Hash
        expect(user_hash.keys).to eq %i[tagged tags time]
      end
    end
  end
end
