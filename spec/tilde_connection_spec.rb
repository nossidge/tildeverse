#!/usr/bin/env ruby

describe 'Tildeverse::TildeConnection' do
  example = [
    'example',
    'http://example.com/',
    'http://example.com/foo'
  ]
  google = [
    'google',
    'http://google.com',
    'http://google.com/foo'
  ]
  malformed = [
    'malformed home page',
    'bar://www.malformedurl.com',
    'bar://www.malformedurl.com/foo'
  ]
  http = [
    'tilde town',
    'http://tilde.town'
  ]
  https = [
    'tilde town',
    'https://tilde.town'
  ]

  it '#get' do
    tc = Tildeverse::TildeConnection.new(*example)
    expect(tc.get).to eq tc.result
    expect(tc.result).to be_nil
    expect(tc.error).to be true
    expect(tc.error_message).to eq "URL is currently offline: #{example[2]}"

    tc = Tildeverse::TildeConnection.new(*google)
    expect(tc.get).to eq tc.result
    expect(tc.result).to be_nil
    expect(tc.error).to be true
    expect(tc.error_message).to eq "URL is currently offline: #{google[2]}"

    tc = Tildeverse::TildeConnection.new(*malformed)
    expect(tc.get).to eq tc.result
    expect(tc.result).to be_nil
    expect(tc.error).to be true
    expect(tc.error_message).to eq "URL is currently offline: #{malformed[1]}"

    tc = Tildeverse::TildeConnection.new(*http)
    expect(tc.url_root).to eq tc.url_list
    expect(tc.get).to eq tc.result
    expect(tc.result).to_not be_nil
    expect(tc.error).to be false
    expect(tc.error_message).to be_nil

    tc = Tildeverse::TildeConnection.new(*https)
    expect(tc.url_root).to eq tc.url_list
    expect(tc.get).to eq tc.result
    expect(tc.result).to_not be_nil
    expect(tc.error).to be false
    expect(tc.error_message).to be_nil
  end
end
