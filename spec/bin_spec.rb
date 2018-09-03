#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative File.expand_path('../../bin/bin_lib/bin', __FILE__)

describe 'Tildeverse::Bin' do
  describe '#argv_orig' do
    it 'should return the original argv passed to the initializer' do
      [
        %w[],
        %w[foo],
        %w[user foo],
        %w[user foo -l],
        %w[user foo -j],
        %w[user foo -jp],
      ].each do |i|
        bin = Tildeverse::Bin.new(i)
        expect(bin.argv_orig).to eq i
      end
    end
  end

  describe '#argv' do
    it 'should return the non-switch arguments' do
      [
        [%w[],                  %w[]],
        [%w[foo],               %w[foo]],
        [%w[user foo],          %w[user foo]],
        [%w[user foo -l],       %w[user foo]],
        [%w[user foo -j],       %w[user foo]],
        [%w[user foo -jp],      %w[user foo]],
        [%w[user foo --pretty], %w[user foo]]
      ].each do |i|
        bin = Tildeverse::Bin.new(i.first)
        expect(bin.argv).to eq i.last
      end
    end
  end

  describe '#options' do
    it 'should return the switch arguments as a hash' do
      [
        [%w[],                  {}],
        [%w[foo],               {}],
        [%w[user foo],          {}],
        [%w[user foo -l],       {long: true}],
        [%w[user foo -j],       {json: true}],
        [%w[user foo -jp],      {json: true, pretty: true}],
        [%w[user foo --pretty], {pretty: true}]
      ].each do |i|
        bin = Tildeverse::Bin.new(i.first)
        expect(bin.options).to eq i.last
      end
    end
  end

  ##############################################################################

  describe '#run' do
    let(:instance) do
      ->(argv) do
        Tildeverse::Bin.new(argv).tap do |bin|
          allow(bin).to receive(:tildeverse_help)
          allow(bin).to receive(:tildeverse_version)
          allow(bin).to receive(:tildeverse_scrape)
          allow(bin).to receive(:tildeverse_fetch)
          allow(bin).to receive(:tildeverse_new)
          allow(bin).to receive(:tildeverse_json)
          allow(bin).to receive(:tildeverse_sites)
          allow(bin).to receive(:tildeverse_site)
          allow(bin).to receive(:tildeverse_users)
        end
      end
    end

    it 'should output help message' do
      bin = instance.call(['help'])
      expect(bin).to receive(:tildeverse_help)
      bin.run
    end

    it 'should output version' do
      bin = instance.call(['version'])
      expect(bin).to receive(:tildeverse_version)
      bin.run
    end

    it 'should scrape from remote' do
      bin = instance.call(['scrape'])
      expect(bin).to receive(:tildeverse_scrape)
      bin.run
    end

    it 'should fetch from remote' do
      bin = instance.call(['fetch'])
      expect(bin).to receive(:tildeverse_fetch)
      bin.run
    end

    it 'should check for new Tilde sites' do
      bin = instance.call(['new'])
      expect(bin).to receive(:tildeverse_new)
      bin.run
    end

    it 'should output the JSON file' do
      bin = instance.call(['json'])
      expect(bin).to receive(:tildeverse_json)
      bin.run
    end

    it 'should list the Tilde sites' do
      bin = instance.call(['sites'])
      expect(bin).to receive(:tildeverse_sites)
      bin.run
    end

    it 'should list users for the site' do
      %w[s site].each do |arg|
        bin = instance.call([arg])
        expect(bin).to receive(:tildeverse_site)
        bin.run
      end
    end

    it 'should list users by URL' do
      %w[u user' users].each do |arg|
        bin = instance.call([arg])
        expect(bin).to receive(:tildeverse_users)
        bin.run
      end
    end
  end

  ##############################################################################

  describe '#tildeverse_help' do
    it 'should return a multi-line string' do
      bin = Tildeverse::Bin.new([])
      help = capture_stdout do
        bin.tildeverse_help
      end.chomp
      expect(help).to be_a String
      expect(help.split("\n").count).to be >= 10
    end
  end

  describe '#tildeverse_version' do
    it 'should contain the version number and date' do
      bin = Tildeverse::Bin.new([])
      version = capture_stdout do
        bin.tildeverse_version
      end.chomp
      expect(version).to be_a String
      expect(version).to include(Tildeverse.version_number)
      expect(version).to include(Tildeverse.version_date)
    end
  end

  ##############################################################################

  describe '#tildeverse_scrape' do
    it 'should delegate to Tildeverse#scrape' do
      allow(Tildeverse).to receive(:scrape).and_return(nil)
      expect(Tildeverse).to receive(:scrape)
      Tildeverse::Bin.new([]).tildeverse_scrape
    end
  end

  describe '#tildeverse_fetch' do
    it 'should delegate to Tildeverse#fetch' do
      allow(Tildeverse).to receive(:fetch).and_return(nil)
      expect(Tildeverse).to receive(:fetch)
      Tildeverse::Bin.new([]).tildeverse_fetch
    end
  end

  describe '#tildeverse_new' do
    it 'should delegate to Tildeverse::PFHawkins#puts_if_new' do
      allow(Tildeverse::PFHawkins).to receive(:puts_if_new).and_return(nil)
      expect_any_instance_of(Tildeverse::PFHawkins).to receive(:puts_if_new)
      Tildeverse::Bin.new([]).tildeverse_new
    end
  end

  ##############################################################################

  describe '#tildeverse_json' do
    let(:serialized_json) do
      Tildeverse.data.serialize.for_tildeverse_json
    end

    it 'should output the unprettified JSON' do
      bin = Tildeverse::Bin.new([])
      output = capture_stdout do
        bin.tildeverse_json
      end.chomp
      expect(output).to eq serialized_json.to_json
    end

    it 'should output the prettified JSON' do
      bin = Tildeverse::Bin.new(['--pretty'])
      output = capture_stdout do
        bin.tildeverse_json
      end.chomp
      expect(output).to eq JSON.pretty_generate(serialized_json)
    end
  end

  ##############################################################################

  describe '#tildeverse_sites(regex)' do
    it 'should return the correct sites' do
      bin = Tildeverse::Bin.new([])
      [
        ['foo',        []],
        ['pebble.ink', %w[pebble.ink]],
        ['pebb',       %w[pebble.ink]],
        ['ink$',       %w[pebble.ink]],
        ['ebb.*k',     %w[pebble.ink]],
        ['tilde',      %w[tilde.club tilde.team tilde.town yourtilde.com]],
        ['^http://p',  %w[palvelin.club pebble.ink protocol.club]],
        ['com$',       %w[ofmanytrades.com yourtilde.com]],
        ['pebb|town',  %w[pebble.ink tilde.town]]
      ].each do |args|
        output = capture_stdout do
          bin.tildeverse_sites(args.first)
        end.chomp
        expect(output).to eq args.last.join("\n")
      end
    end

    it 'should return the correct sites in long format' do
      bin = Tildeverse::Bin.new(['--long'])
      %w[foo pebble.ink pebb ink$ ebb.*k tilde ^http://p com$].each do |args|
        output = capture_stdout do
          bin.tildeverse_sites(args)
        end.chomp

        # Just check for the headers
        %w[NAME URL USERS].each do |header|
          expect(output.split("\n").first).to include(header)
        end
      end
    end
  end

  describe '#tildeverse_site(regex)' do
    it 'should return the correct users' do
      bin = Tildeverse::Bin.new([])
      [
        ['foo',        []],
        ['pebble.ink', %w[pebble.ink]],
        ['pebb',       %w[pebble.ink]],
        ['ink$',       %w[pebble.ink]],
        ['ebb.*k',     %w[pebble.ink]],
        ['tilde',      %w[tilde.club tilde.team tilde.town yourtilde.com]],
        ['^http://p',  %w[palvelin.club pebble.ink protocol.club]],
        ['com$',       %w[ofmanytrades.com yourtilde.com]],
        ['pebb|town',  %w[pebble.ink tilde.town]]
      ].each do |args|
        output = capture_stdout do
          bin.tildeverse_site(args.first)
        end.chomp

        # Should match the users of the site(s)
        names = args.last.map do |site_name|
          Tildeverse.site(site_name).users.map(&:name)
        end.flatten.compact
        expect(output).to eq names.join("\n")
      end
    end

    it 'should return the correct users in long format' do
      bin = Tildeverse::Bin.new(['--long'])
      %w[foo pebble.ink pebb ink$ ebb.*k tilde ^http://p com$].each do |i|
        output = capture_stdout do
          bin.tildeverse_site(i)
        end.chomp

        # Just check for the headers
        %w[SITE NAME URL MODIFIED TAGGED TAGS].each do |header|
          expect(output.split("\n").first).to include(header)
        end
      end
    end
  end

  describe '#tildeverse_users(regex)' do
    it 'should return the correct users' do
      bin = Tildeverse::Bin.new([])
      [
        ['foobarbaz', []],
        ['noss',      %w[nossidge]],
        ['c',         %w[clach04 contolini elzilrac]],
      ].each do |args|
        output = capture_stdout do
          bin.tildeverse_users(args.first)
        end.chomp

        args.last.each do |user_name|
          expect(output).to include(user_name)
        end
      end
    end

    it 'should return the correct users in long format' do
      bin = Tildeverse::Bin.new(['--long'])
      %w[foobarbaz noss c].each do |i|
        output = capture_stdout do
          bin.tildeverse_site(i)
        end.chomp

        # Just check for the headers
        %w[SITE NAME URL MODIFIED TAGGED TAGS].each do |header|
          expect(output.split("\n").first).to include(header)
        end
      end
    end
  end

  ##############################################################################

  describe '#parse(args)' do
    it 'should update the correct attributes' do
      [
        [%w[],                  {}],
        [%w[foo],               {}],
        [%w[user foo],          {}],
        [%w[user foo -l],       {long: true}],
        [%w[user foo -j],       {json: true}],
        [%w[user foo -jp],      {json: true, pretty: true}],
        [%w[user foo --pretty], {pretty: true}]
      ].each do |args|
        bin = Tildeverse::Bin.new([])
        after_parse = bin.send(:parse, args.first)
        expect(bin.options).to eq args.last
        expect(bin.argv).to eq after_parse
        expect(bin.argv_orig).to eq args.first
      end
    end
  end

  ##############################################################################

  describe '#format_users(users)' do
    let(:user) { Tildeverse.user('nossidge') }
    let(:json) { Tildeverse.data.serialize.users(user) }
    let(:call) { ->(options) {
      Tildeverse::Bin.new(options).send(:format_users, user) { 'default' }
    } }

    it 'should call and return the block if no special options' do
      options = {}
      expect(call[options]).to eq 'default'
    end

    it 'should return a whitespace-delimited array if options[:long]' do
      options = { long: true }
      expect(call[options]).to eq Tildeverse.data.serialize.users_as_wsv(user)
    end

    it 'should return a JSON string if options[:json]' do
      options = { json: true }
      expect(call[options]).to eq json.to_json
    end

    it 'should return a pretty JSON string if options[:pretty]' do
      options = { pretty: true }
      expect(call[options]).to eq JSON.pretty_generate(json)
    end
  end

  describe '#format_sites(sites)' do
    let(:site) { Tildeverse.site('pebble.ink') }
    let(:json) { Tildeverse.data.serialize.sites(site) }
    let(:call) { ->(options) {
      Tildeverse::Bin.new(options).send(:format_sites, site) { 'default' }
    } }

    it 'should call and return the block if no special options' do
      options = {}
      expect(call[options]).to eq 'default'
    end

    it 'should return a whitespace-delimited array if options[:long]' do
      options = { long: true }
      expect(call[options]).to eq Tildeverse.data.serialize.sites_as_wsv(site)
    end

    it 'should return a JSON string if options[:json]' do
      options = { json: true }
      expect(call[options]).to eq json.to_json
    end

    it 'should return a pretty JSON string if options[:pretty]' do
      options = { pretty: true }
      expect(call[options]).to eq JSON.pretty_generate(json)
    end
  end
end
