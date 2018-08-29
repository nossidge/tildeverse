#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse' do
  describe '#config' do
    it 'should return a Config instance' do
      expect(Tildeverse.config).to be_a Tildeverse::Config
    end
  end

  describe '#data' do
    it 'should return a Data instance' do
      expect(Tildeverse.data).to be_a Tildeverse::Data
    end
  end

  describe '#sites' do
    it 'should delegate to Data#sites' do
      expect_any_instance_of(Tildeverse::Data).to receive(:sites)
      Tildeverse.sites
    end
  end

  describe '#site' do
    it 'should delegate to Data#site' do
      site = 'pebble.ink'
      expect_any_instance_of(Tildeverse::Data).to receive(:site).with(site)
      Tildeverse.site(site)
    end
  end

  describe '#users' do
    it 'should only show online users' do
      actual   = Tildeverse.users
      expected = Tildeverse.data.users.select(&:online?)
      expect(actual).to eq expected
    end
  end

  describe '#user' do
    it 'should only show user if online' do
      user_name = 'nossidge'
      actual   = Tildeverse.user(user_name)
      expected = Tildeverse.data.user(user_name).select(&:online?)
      expect(actual).to eq expected
    end
  end

  describe '#new?' do
    it 'should delegate to PFHawkins#new?' do
      expect_any_instance_of(Tildeverse::PFHawkins).to receive(:new?)
      Tildeverse.new?
    end
  end

  describe '#get' do
    it 'should call the correct method based on Config#update_type' do
      config_with_scrape = Class.new do
        def update_type
          :scrape
        end
      end
      config_with_fetch = Class.new do
        def update_type
          :fetch
        end
      end
      allow(Tildeverse).to receive(:scrape).and_return('I will scrape')
      allow(Tildeverse).to receive(:fetch).and_return('I will fetch')

      allow(Tildeverse).to receive(:config).and_return(config_with_scrape.new)
      expect(Tildeverse.get).to eq 'I will scrape'

      allow(Tildeverse).to receive(:config).and_return(config_with_fetch.new)
      expect(Tildeverse.get).to eq 'I will fetch'
    end

    it 'should error if Config#update_type is not implemented' do
      config_with_dodgy = Class.new do
        def update_type
          :dodgy
        end
      end
      allow(Tildeverse).to receive(:config).and_return(config_with_dodgy.new)
      msg = "Config variable 'update_type' is not valid"
      expect{ Tildeverse.get }.to raise_error(ArgumentError, msg)
    end
  end

  describe '#scrape' do
    it 'should delegate to Scraper#scrape' do
      allow_any_instance_of(Tildeverse::Scraper).to(
        receive(:scrape).and_return('I have scraped')
      )
      expect(Tildeverse.scrape).to eq 'I have scraped'
    end
  end

  describe '#fetch' do
    it 'should delegate to Fetcher#fetch' do
      allow_any_instance_of(Tildeverse::Fetcher).to(
        receive(:fetch).and_return('I have fetched')
      )
      expect(Tildeverse.fetch).to eq 'I have fetched'
    end
  end

  describe '#save' do
    it 'should delegate to Data#save_with_config' do
      allow_any_instance_of(Tildeverse::Data).to(
        receive(:save_with_config).and_return('I have saved')
      )
      expect(Tildeverse.save).to eq 'I have saved'
    end
  end
end
