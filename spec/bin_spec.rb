#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative File.expand_path('../../bin/bin_lib/bin', __FILE__)

describe 'Tildeverse::Bin' do
  let(:bin) { Tildeverse::Bin.new([]) }

  describe '#new' do
    it 'should correctly apply the -f option' do
      expect(Tildeverse.suppress).to eq []
      Tildeverse::Bin.new(%w[foo -f])
      expect(Tildeverse.suppress).to eq [Tildeverse::Error::OfflineURIError]
    end

    it 'should print info and exit on --help option' do
      expect do
        capture_stdout { Tildeverse::Bin.new(%w[--help]) }
      end.to raise_error(SystemExit)
      allow_any_instance_of(Tildeverse::Bin).to receive(:exit)
      output = capture_stdout { Tildeverse::Bin.new(%w[--help]) }
      expect(output).to eq bin.send(:option_parser).to_s.chomp
    end

    it 'should print info and exit on --version option' do
      expect do
        capture_stdout { Tildeverse::Bin.new(%w[--version]) }
      end.to raise_error(SystemExit)
      allow_any_instance_of(Tildeverse::Bin).to receive(:exit)
      output = capture_stdout { Tildeverse::Bin.new(%w[--version]) }
      expect(output).to eq bin.send(:version_text).to_s.chomp
    end

    it 'should print error info and exit on incorrect option' do
      expect do
        capture_stdout { Tildeverse::Bin.new(%w[--foo]) }
      end.to raise_error(SystemExit)
      allow_any_instance_of(Tildeverse::Bin).to receive(:exit)
      output = capture_stdout { Tildeverse::Bin.new(%w[--foo]) }
      expect(output).to eq 'invalid option: --foo'
    end
  end

  ##############################################################################

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
          allow(bin).to receive(:tildeverse_scrape)
          allow(bin).to receive(:tildeverse_fetch)
          allow(bin).to receive(:tildeverse_new)
          allow(bin).to receive(:tildeverse_json)
          allow(bin).to receive(:tildeverse_sites)
          allow(bin).to receive(:tildeverse_users)
        end
      end
    end

    it 'should get from remote' do
      bin = instance.call(['get'])
      expect(bin).to receive(:tildeverse_get)
      bin.run
    end

    it 'should fail to call get when unauthorised' do
      bin = instance.call(['get'])
      allow(bin).to receive(:authorised?).and_return(false)
      expect(bin).to_not receive(:tildeverse_get)
      bin.run
    end

    it 'should scrape from remote' do
      bin = instance.call(['scrape'])
      expect(bin).to receive(:tildeverse_scrape)
      bin.run
    end

    it 'should fail to call scrape when unauthorised' do
      bin = instance.call(['scrape'])
      allow(bin).to receive(:authorised?).and_return(false)
      expect(bin).to_not receive(:tildeverse_scrape)
      bin.run
    end

    it 'should fetch from remote' do
      bin = instance.call(['fetch'])
      expect(bin).to receive(:tildeverse_fetch)
      bin.run
    end

    it 'should fail to call fetch when unauthorised' do
      bin = instance.call(['fetch'])
      allow(bin).to receive(:authorised?).and_return(false)
      expect(bin).to_not receive(:tildeverse_fetch)
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
      %w[s site sites].each do |arg|
        bin = instance.call([arg])
        expect(bin).to receive(:tildeverse_sites)
        bin.run
      end
    end

    it 'should list users by URL' do
      %w[u user users].each do |arg|
        bin = instance.call([arg])
        expect(bin).to receive(:tildeverse_users)
        bin.run
      end
    end
  end

  ##############################################################################

  tildeverse_delegate = proc do |get_type|
    describe "#tildeverse_#{get_type}" do
      it "should delegate to Tildeverse##{get_type}" do
        allow(Tildeverse).to receive(get_type).and_return(nil)
        expect(Tildeverse).to receive(get_type)
        Tildeverse::Bin.new([]).send("tildeverse_#{get_type}")
      end
    end
  end
  tildeverse_delegate.call(:get)
  tildeverse_delegate.call(:scrape)
  tildeverse_delegate.call(:fetch)

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
      output = capture_stdout { bin.tildeverse_json }
      expect(output).to eq serialized_json.to_json
    end

    it 'should output the prettified JSON' do
      bin = Tildeverse::Bin.new(['--pretty'])
      output = capture_stdout { bin.tildeverse_json }
      expect(output).to eq JSON.pretty_generate(serialized_json)
    end
  end

  ##############################################################################

  describe '#tildeverse_sites' do
    it 'should return the correct sites' do
      [
        ['-s foo',        []],
        ['-s pebble.ink', %w[pebble.ink]],
        ['-s pebb',       %w[pebble.ink]],
        ['-s ink$',       %w[pebble.ink]],
        ['-s ebb.*k',     %w[pebble.ink]],
        ['-s tilde',      %w[tilde.club tilde.town]],
        ['-s e',          %w[pebble.ink tilde.club tilde.town]],
        ['-s pebb|town',  %w[pebble.ink tilde.town]],
        ['-t blog',       %w[pebble.ink]],
        ['-u foo',        %w[tilde.club]],
        ['-u f',          %w[pebble.ink tilde.club]],
        ['-U f',          %w[pebble.ink tilde.town]],
        ['-U noss',       %w[pebble.ink tilde.club]],
        ['-T empty',      %w[pebble.ink tilde.town]],
        ['-S tilde',      %w[pebble.ink]],
        ['--http',        %w[pebble.ink tilde.club]],
        ['--https',       %w[tilde.town]]
      ].each do |args|
        bin = Tildeverse::Bin.new(args.first.split)
        output = capture_stdout { bin.tildeverse_sites }
        expect(output).to eq args.last.join("\n")
      end
    end

    it 'should return the correct sites in long format' do
      %w[foo pebble.ink pebb ink$ ebb.*k tilde com$].each do |regex|
        args = ['--long', '--site', regex]
        bin = Tildeverse::Bin.new(args)
        output = capture_stdout { bin.tildeverse_sites }

        # Just check for the headers
        %w[NAME URL USERS].each do |header|
          expect(output.split("\n").first).to include(header)
        end
      end
    end
  end

  describe '#tildeverse_users' do
    it 'should return the correct users' do
      [
        ['-u foobarbaz', []],
        ['-u noss',      %w[nossidge]],
        ['-u c',         %w[clach04 contolini elzilrac]],
        ['-s club',      %w[foo_user]],
        ['-t blog',      %w[jovan phildini]],
        ['-U e',         %w[clach04 contolini imt jovan phildini]],
        ['-T e',         %w[jovan ke7ofi phildini]],
        ['-S pebble',    %w[foo_user nossidge]],
        ['--https',      %w[nossidge]]
      ].each do |args|
        bin = Tildeverse::Bin.new(args.first.split)
        output = capture_stdout { bin.tildeverse_users }

        args.last.each do |user_name|
          expect(output).to include(user_name)
        end
      end
    end

    it 'should return the correct users in long format' do
      %w[foobarbaz noss c].each do |regex|
        args = ['--long', '--user', regex]
        bin = Tildeverse::Bin.new(args)
        output = capture_stdout { bin.tildeverse_users }

        # Just check for the headers
        %w[SITE NAME URL MODIFIED TAGGED TAGS].each do |header|
          expect(output.split("\n").first).to include(header)
        end
      end
    end
  end

  ##############################################################################

  describe '#help_text' do
    it 'should return a multi-line string' do
      bin = Tildeverse::Bin.new([])
      help = bin.send('help_text')
      expect(help).to be_a String
      expect(help.split("\n").count).to be >= 10
    end

    show_get = proc do |is_authorised, expectation|
      i = is_authorised ? '' : 'not '
      it "should #{i}display info about data gets if #{i}authorised" do
        bin = Tildeverse::Bin.new([])
        allow(bin).to receive(:authorised?).and_return(is_authorised)
        help = bin.send('help_text')
        [
          '$ tildeverse get',
          '$ tildeverse scrape',
          '$ tildeverse fetch'
        ].each do |i|
          expect(help).send(expectation, include(i))
        end
      end
    end
    show_get.call(true,  :to)
    show_get.call(false, :to_not)
  end

  describe '#version_text' do
    it 'should contain the version number and date' do
      bin = Tildeverse::Bin.new([])
      version = bin.send('version_text')
      expect(version).to be_a String
      expect(version).to include(Tildeverse.version_number)
      expect(version).to include(Tildeverse.version_date)
    end
  end

  ##############################################################################

  describe '#parse(args)' do
    it 'should update the correct attributes' do
      [
        [%w[],                     {}],
        [%w[-u foo],               {user: 'foo'}],
        [%w[user -u foo],          {user: 'foo'}],
        [%w[user -u foo -l],       {user: 'foo', long: true}],
        [%w[user -u foo -j],       {user: 'foo', json: true}],
        [%w[user -u foo -jp],      {user: 'foo', json: true, pretty: true}],
        [%w[site -u foo --pretty], {user: 'foo', pretty: true}],
        [%w[-t blog -s club],      {tag: 'blog', site: 'club'}],
        [%w[-ojp],                 {offline: true, json: true, pretty: true}],
        [%w[--offline -jp],        {offline: true, json: true, pretty: true}],
        [%w[scrape -f],            {force: true}],
        [%w[-T blog -S club],      {xtag: 'blog', xsite: 'club'}],
        [%w[-T blog -U noss],      {xtag: 'blog', xuser: 'noss'}],
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

  ##############################################################################

  describe '#puts' do
    let(:bin) { Tildeverse::Bin.new([]) }
    let(:msg) { 'foo bar' }

    it 'should return nil from the ordinary puts method' do
      expect(STDOUT).to receive(:puts).with(msg)
      expect do
        result = bin.send(:puts, msg)
        expect(result).to be nil
      end.not_to raise_error
    end

    it 'should rescue from StandardError and still return nil' do
      allow_any_instance_of(Kernel).to receive(:puts).and_raise(StandardError)
      expect do
        result = bin.send(:puts, msg)
        expect(result).to be nil
      end.not_to raise_error
    end
  end
end
