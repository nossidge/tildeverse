#!/usr/bin/env ruby

describe 'Tildeverse::PFHawkins' do
  let(:instance) do
    Tildeverse::PFHawkins.new
  end

  describe '#url_html' do
    it 'should be a valid URI' do
      expect do
        URI(instance.url_html)
      end.to_not raise_error
    end
    it 'should respond correctly to HTTP GET' do
      uri = URI(instance.url_html)
      res = Net::HTTP.get_response(uri)
      expect(res.code).to eq '200'
    end
  end

  describe '#url_json' do
    it 'should be a valid URI' do
      expect do
        URI(instance.url_json)
      end.to_not raise_error
    end
    it 'should respond correctly to HTTP GET' do
      uri = URI(instance.url_json)
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
    it 'should return the correct boolean' do
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
  end

  describe '#puts_if_new' do
    it 'should not output if #new? is false' do
      expect(STDOUT).to_not receive(:puts)
      instance.puts_if_new
    end
    it 'should output to STDOUT if #new? is true' do
      allow(instance).to receive(:new?).and_return(true)
      msg = "-- New Tilde Boxes!\n" + instance.url_html
      expect(STDOUT).to receive(:puts).with(msg)
      instance.puts_if_new
    end
  end
end
