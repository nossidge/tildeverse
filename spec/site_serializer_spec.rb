#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::SiteSerializer' do
  let(:example_data) do
    {
      'https://tilde.town/~dan/users.json' => {
        name:             'tilde.town',
        root:             'https://tilde.town',
        list:             'https://tilde.town/~dan/users.json',
        homepage_format:  'https://tilde.town/~USER/'
      },
      'http://example.com' => {
        name:             'example.com',
        root:             'http://example.com',
        list:             'http://example.com',
        homepage_format:  'http://example.com/~USER/'
      }
    }
  end

  let(:klass) do
    Class.new(Tildeverse::Site) do
      def scrape_users; 'foo'; end
      def online?; 'foo'; end
    end
  end

  let(:site_from_uri) { ->(uri) {
    tilde_site_uri = Tildeverse::TildeSiteURI.new(uri)
    klass.new(tilde_site_uri)
  } }

  let(:serializer_from_site) { ->(site) {
    Tildeverse::SiteSerializer.new(site)
  } }

  ##############################################################################

  describe '#to_s' do
    let(:uri)          { example_data.first.first }
    let(:expectations) { example_data.first.last }
    let(:site)         { site_from_uri[uri] }
    let(:serializer)   { serializer_from_site[site] }

    it 'should return a string' do
      expect(serializer.to_s).to be_a String
    end

    it 'should return correct data' do
      expect(serializer.to_s).to eq ({
        name:             site.name,
        root:             site.uri.root,
        list:             site.uri.list,
        homepage_format:  site.uri.homepage_format,
        online?:          site.online?,
        users:            site.users.count,
        users_online:     site.users_online.count
      }.to_s)
    end
  end

  ##############################################################################

  describe '#for_tildeverse_json' do
    it 'should return correct data' do
      example_data.each do |uri, expectations|
        site = site_from_uri[uri]
        serializer = serializer_from_site[site]
        expectations.each do |message, result|
          expect(site.uri.send(message)).to eq result
        end
        hash = serializer.for_tildeverse_json
        expect(hash).to be_a Hash
        keys = %i[url_root url_list url_format_user online user_count users]
        expect(hash.keys).to eq keys
        expect(hash[:url_root]).to eq expectations[:root]
        expect(hash[:url_list]).to eq expectations[:list]
        expect(hash[:url_format_user]).to eq expectations[:homepage_format]
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
end
