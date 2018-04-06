#!/usr/bin/env ruby

describe 'Tildeverse::PFHawkins' do
  def instance
    @instance ||= Tildeverse::PFHawkins.new
  end

  def instance_with_new_box
    singleton = Tildeverse::PFHawkins.new
    def singleton.count
      20
    end
    singleton
  end

  it '#url_html' do
    uri = URI(instance.url_html)
    res = Net::HTTP.get_response(uri)
    expect(res.code).to eq '200'
  end

  it '#url_json' do
    uri = URI(instance.url_json)
    res = Net::HTTP.get_response(uri)
    expect(res.code).to eq '200'
  end

  it '#servers' do
    servers = instance.servers
    expect(servers).to be_a Array
    sites = instance.sites
    expect(sites).to be_a Array
    boxes = instance.boxes
    expect(boxes).to be_a Array
    expect(servers).to eq sites
    expect(servers).to eq boxes
  end

  it '#count' do
    count = instance.count
    expect(count).to be_a Integer
  end

  it '#new?' do
    has_new = instance.new?
    expect(has_new).to be false

    has_new = instance_with_new_box.new?
    expect(has_new).to be true
  end

  it '#puts_if_new' do
    singleton = instance_with_new_box
    msg = "-- New Tilde Boxes!\n" + singleton.url_html
    expect(STDOUT).to receive(:puts).with(msg)
    singleton.puts_if_new
  end
end
