#!/usr/bin/env ruby

describe 'Tildeverse::ModifiedDates' do
  def instance
    @instance ||= Tildeverse::ModifiedDates.new
  end

  it '#data' do
    result = instance.data

    expect(result).to be_a Array
    expect(result.first).to be_a Hash

    expect(result.first[:site]).to_not be_nil
    expect(result.first[:user]).to_not be_nil
    expect(result.first[:time]).to_not be_nil
    expect(result.first[:junk]).to be_nil

    result.each do |i|
      Time.strptime(i[:time], '%Y-%m-%d')
    end
  end

  it '#for_user' do
    [
      ['tilde.town', 'nossidge'],
      ['pebble.ink', 'imt']
    ].each do |i|
      result = instance.for_user(i.first, i.last)
      expect(result).to_not be_nil
    end

    [
      ['pebble.ink', 'foobarbazfring'],
      ['example.com', 'imt'],
      ['', ''],
      ['pebble.ink', nil],
      [nil, nil]
    ].each do |i|
      result = instance.for_user(i.first, i.last)
      expect(result).to be_nil
    end
  end
end
