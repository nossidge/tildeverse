#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Fetcher' do

  # Implement the bare minimum to quack like a Data object
  let(:data_duck) do
    double('Data', :save_with_config => nil, :clear => nil)
  end

  ##############################################################################

  describe '#fetch' do
    it 'should return true if valid URL' do
      fetcher = Tildeverse::Fetcher.new(data_duck)

      results = nil
      expect { results = fetcher.fetch }.to_not raise_error
      expect(results).to eq true
    end

    it 'should return false if invalid URL' do
      url = 'http://example.com/foo'
      msg = "URL is currently offline: #{url}"
      remote = Tildeverse::RemoteResource.new('foo', url)
      fetcher = Tildeverse::Fetcher.new(data_duck, remote)

      results = nil
      expect(STDOUT).to receive(:puts).with(msg)
      expect { results = fetcher.fetch }.to_not raise_error
      expect(results).to eq false
    end
  end
end
