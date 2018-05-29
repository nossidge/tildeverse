#!/usr/bin/env ruby

describe 'Tildeverse::PFHawkins' do
  def instance
    Tildeverse::PFHawkins.new
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

  it '#new?' do
    alter_servers = ->(&block) do
      pfhawkins = Tildeverse::PFHawkins.new
      expect(pfhawkins.new?).to be false
      servers = pfhawkins.servers.dup
      block.call(servers)
      allow(pfhawkins).to receive(:server_list_cache).and_return(servers)
      expect(pfhawkins.new?).to be true
    end
    alter_servers.call { |servers| servers << 'new-foo.com' }
    alter_servers.call { |servers| servers.pop }
  end

  it '#puts_if_new' do
    pfhawkins = Tildeverse::PFHawkins.new
    allow(pfhawkins).to receive(:new?).and_return(true)
    msg = "-- New Tilde Boxes!\n" + pfhawkins.url_html
    expect(STDOUT).to receive(:puts).with(msg)
    pfhawkins.puts_if_new
  end
end
