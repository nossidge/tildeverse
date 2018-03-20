#!/usr/bin/env ruby

describe 'Tildeverse::ModifiedDates' do
  def instance
    @instance ||= Tildeverse::ModifiedDates.new
  end

  it '#get' do
    result = instance.get

    expect(result).to be_a Array
    expect(result.first).to be_a Hash

    expect(result.first[:site]).to_not be_nil
    expect(result.first[:user]).to_not be_nil
    expect(result.first[:time]).to_not be_nil
    expect(result.first[:junk]).to be_nil

    result.each do |i|
      Time.strptime(i[:time], '%Y-%m-%dT%H:%M:%S')
    end
  end
end
