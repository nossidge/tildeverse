#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::PFHawkins' do
  let(:instance) do
    Tildeverse::PFHawkins.new
  end

  describe 'Tildeverse::PFHawkins::URL_HTML' do
    it 'should be a valid URI' do
      expect do
        URI(Tildeverse::PFHawkins::URL_HTML)
      end.to_not raise_error
    end
    it 'should respond correctly to HTTP GET' do
      uri = URI(Tildeverse::PFHawkins::URL_HTML)
      res = Net::HTTP.get_response(uri)
      expect(res.code).to eq '200'
    end
  end

  describe 'Tildeverse::PFHawkins::URL_JSON' do
    it 'should be a valid URI' do
      expect do
        URI(Tildeverse::PFHawkins::URL_JSON)
      end.to_not raise_error
    end
    it 'should respond correctly to HTTP GET' do
      uri = URI(Tildeverse::PFHawkins::URL_JSON)
      res = Net::HTTP.get_response(uri)
      expect(res.code).to eq '200'
    end
  end

  describe '#servers' do
    it 'should return an array' do
      servers = instance.servers
      expect(servers).to be_a Array
    end
    it 'should alias to #sites' do
      sites = instance.sites
      expect(sites).to eq instance.servers
    end
    it 'should alias to #boxes' do
      boxes = instance.boxes
      expect(boxes).to eq instance.servers
    end
  end

  describe '#new?' do
    let(:alter_servers) do
      ->(&block) do
        pfhawkins = Tildeverse::PFHawkins.new
        expect(pfhawkins.new?).to be false
        servers = pfhawkins.servers.dup
        block.call(servers)
        stub_const("Tildeverse::PFHawkins::SERVER_LIST", servers)
        expect(pfhawkins.new?).to be true
      end
    end
    it 'should return true if there is a new server' do
      alter_servers.call { |servers| servers << 'new-foo.com' }
    end
    it 'should return true if a server has gone offline' do
      alter_servers.call { |servers| servers.pop }
    end
  end

  describe '#puts_if_new' do
    it 'should not output if #new? is false' do
      expect(STDOUT).to_not receive(:puts)
      instance.puts_if_new
    end
    it 'should output to STDOUT if #new? is true' do
      allow(instance).to receive(:new?).and_return(true)
      msg = "-- New Tilde Boxes!\n" + Tildeverse::PFHawkins::URL_HTML
      expect(STDOUT).to receive(:puts).with(msg)
      instance.puts_if_new
    end
  end
end
