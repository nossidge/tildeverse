#!/usr/bin/env ruby

describe 'Tildeverse::PFHawkins' do

  def instance
    @instance ||= Tildeverse::PFHawkins.new
  end

  it '#html_url' do
    uri = URI(instance.html_url)
    res = Net::HTTP.get_response(uri)
    expect(res.code).to eq '200'
  end

  it '#json_url' do
    uri = URI(instance.json_url)
    res = Net::HTTP.get_response(uri)
    expect(res.code).to eq '200'
  end

  it '#json' do
    json = instance.json
    expect(json).to be_a Hash
  end

  it '#boxes' do
    boxes = instance.boxes
    expect(boxes).to be_a Array
  end

  it '#count' do
    count = instance.count
    expect(count).to be_a Integer
  end

  it '#new?' do
    has_new = instance.new?
    expect(has_new).to be_boolean
  end
end
