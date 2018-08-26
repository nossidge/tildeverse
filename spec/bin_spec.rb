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
    it 'should TODO' do
      # TODO
    end
  end

  ##############################################################################

  describe '#tildeverse_help' do
    it 'should return a multi-line string' do
      bin = Tildeverse::Bin.new([])
      help = bin.tildeverse_help
      expect(help).to be_a String
      expect(help.split("\n").count).to be >= 10
    end
  end

  describe '#tildeverse_version' do
    it 'should contain the version number and date' do
      bin = Tildeverse::Bin.new([])
      version = bin.tildeverse_version
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
end
