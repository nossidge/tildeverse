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

  describe '#get <- example.com' do
    it 'should be offline' do
      tc = Tildeverse::RemoteResource.new(*example)
      expect(tc.get).to eq tc.result
      expect(tc.result).to be_nil
      expect(tc.error?).to be true
      expect(tc.msg).to eq "URL is currently offline: #{example[2]}"
    end
  end

  describe '#get <- google.com' do
    it 'should be offline' do
      tc = Tildeverse::RemoteResource.new(*google)
      expect(tc.get).to eq tc.result
      expect(tc.result).to be_nil
      expect(tc.error?).to be true
      expect(tc.msg).to eq "URL is currently offline: #{google[2]}"
    end
  end

  describe '#get <- malformed home page' do
    it 'should be offline' do
      tc = Tildeverse::RemoteResource.new(*malformed)
      expect(tc.get).to eq tc.result
      expect(tc.result).to be_nil
      expect(tc.error?).to be true
      expect(tc.msg).to eq "URL is currently offline: #{malformed[1]}"
    end
  end

  describe '#get <- http tilde.town' do
    it 'should be online' do
      tc = Tildeverse::RemoteResource.new(*http)
      expect(tc.root).to eq tc.resource
      expect(tc.get).to eq tc.result
      expect(tc.result).to_not be_nil
      expect(tc.error?).to be false
      expect(tc.msg).to be_nil
    end
  end

  describe '#get <- https tilde.town' do
    it 'should be online' do
      tc = Tildeverse::RemoteResource.new(*https)
      expect(tc.root).to eq tc.resource
      expect(tc.get).to eq tc.result
      expect(tc.result).to_not be_nil
      expect(tc.error?).to be false
      expect(tc.msg).to be_nil
    end
  end
end
