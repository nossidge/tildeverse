#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative File.expand_path('../../bin/bin_lib/bin', __FILE__)

describe 'Tildeverse::Bin' do
  describe '#argv_orig' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#argv' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#options' do
    it 'should TODO' do
      # TODO
    end
  end

  ##############################################################################

  describe '#run' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#tildeverse_help' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#tildeverse_version' do
    it 'should TODO' do
      # TODO
    end
  end

  ##############################################################################

  describe '#tildeverse_scrape' do
    it 'should delegate to Tildeverse#scrape' do
      allow(Tildeverse).to receive(:scrape).and_return(nil)
      expect(Tildeverse).to receive(:scrape)
      Tildeverse::Bin.new([]).tildeverse_scrape
    end
  end

  describe '#tildeverse_fetch' do
    it 'should delegate to Tildeverse#fetch' do
      allow(Tildeverse).to receive(:fetch).and_return(nil)
      expect(Tildeverse).to receive(:fetch)
      Tildeverse::Bin.new([]).tildeverse_fetch
    end
  end

  describe '#tildeverse_new' do
    it 'should delegate to Tildeverse::PFHawkins#puts_if_new' do
      allow(Tildeverse::PFHawkins).to receive(:puts_if_new).and_return(nil)
      expect_any_instance_of(Tildeverse::PFHawkins).to receive(:puts_if_new)
      Tildeverse::Bin.new([]).tildeverse_new
    end
  end

  ##############################################################################

  describe '#tildeverse_json' do
    it 'should TODO' do
      # TODO
    end
  end

  ##############################################################################

  describe '#tildeverse_sites(regex)' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#tildeverse_site(regex)' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#tildeverse_users(regex)' do
    it 'should TODO' do
      # TODO
    end
  end

  ##############################################################################

  describe '#parse(args)' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#output_users(users)' do
    it 'should TODO' do
      # TODO
    end
  end

  describe '#output_sites(sites)' do
    it 'should TODO' do
      # TODO
    end
  end
end
