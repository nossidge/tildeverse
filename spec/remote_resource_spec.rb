#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::RemoteResource' do
  example = [
    'example.com',
    'http://example.com/',
    'http://example.com/foo'
  ]
  google = [
    'google.com',
    'http://google.com',
    'http://google.com/foo'
  ]
  malformed = [
    'malformed home page',
    'bar://www.malformedurl.com',
    'bar://www.malformedurl.com/foo'
  ]
  http = [
    'http tilde.town',
    'http://tilde.town'
  ]
  https = [
    'https tilde.town',
    'https://tilde.town'
  ]

  let(:error) { Tildeverse::Error::OfflineURIError }

  describe '#get <- example.com' do
    it 'should raise Error::OfflineURIError' do
      tc = Tildeverse::RemoteResource.new(*example)
      msg = %(URI is offline: "#{example[2]}")
      expect{ tc.get }.to raise_error(error, msg)
    end
  end

  describe '#get <- google.com' do
    it 'should raise Error::OfflineURIError' do
      tc = Tildeverse::RemoteResource.new(*google)
      msg = %(URI is offline: "#{google[2]}")
      expect{ tc.get }.to raise_error(error, msg)
    end
  end

  describe '#get <- malformed home page' do
    it 'should raise Error::OfflineURIError' do
      tc = Tildeverse::RemoteResource.new(*malformed)
      msg = %(URI is offline: "#{malformed[1]}")
      expect{ tc.get }.to raise_error(error, msg)
    end
  end

  describe '#get <- http tilde.town' do
    it 'should be online' do
      tc = Tildeverse::RemoteResource.new(*http)
      expect(tc.root).to eq tc.resource
      expect(tc.get).to eq tc.result
      expect(tc.result).to_not be_nil
      expect(tc.error?).to be false
    end
  end

  describe '#get <- https tilde.town' do
    it 'should be online' do
      tc = Tildeverse::RemoteResource.new(*https)
      expect(tc.root).to eq tc.resource
      expect(tc.get).to eq tc.result
      expect(tc.result).to_not be_nil
      expect(tc.error?).to be false
    end
  end
end
