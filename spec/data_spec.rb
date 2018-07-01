#!/usr/bin/env ruby

describe 'Tildeverse::Data' do

  # Same info as Config class, but not tied to a file on the system.
  let(:config_struct) do
    Struct.new(
      :update_type,
      :update_frequency,
      :generate_html,
      :updated_on
    ) do
      def generate_html?; generate_html; end
      def update; nil; end
    end
  end

  let(:config) do
    config_struct.new('scrape', 'week', false, '2018-06-08')
  end

  let(:instance) do
    Tildeverse::Data.new(config)
  end

  ##############################################################################

  it '#serialize' do
    serializer = instance.serialize
    expect(serializer).to be_a Tildeverse::DataSerializer
  end

  it '#config' do
    expect(instance.config).to eq config
  end

  # This should include one object of each 'Sites' class.
  it '#sites' do
    sites = instance.sites.map(&:class)
    expect(sites).to eq Tildeverse::Sites.classes
  end

  it '#site' do
    data = instance
    site = data.site('pebble.ink')
    expect(site).to be_a Tildeverse::Sites::PebbleInk
    site = data.site('tilde.town')
    expect(site).to be_a Tildeverse::Sites::TildeTown
    site = data.site('foo-bar.example')
    expect(site).to be nil
  end

  it '#users' do
    users = instance.users
    expect(users).to all be_a Tildeverse::User
  end

  it '#user' do
    data = instance
    %w[nossidge imt foobar_no_name].each do |username|
      users = data.user(username)
      expect(users).to all be_a Tildeverse::User
      names = users.map(&:name)
      expect(names).to all eq username
    end
  end

  it '#save' do
    data = instance
    expect(Tildeverse::DataSaver).to receive(:new).with(data).and_call_original
    expect_any_instance_of(Tildeverse::DataSaver).to receive(:save)
    data.save
  end

  it '#save_website' do
    data = instance
    expect(Tildeverse::DataSaver).to receive(:new).with(data).and_call_original
    expect_any_instance_of(Tildeverse::DataSaver).to receive(:save_website)
    data.save_website
  end

  it '#save_with_config' do
    data = instance
    expect(Tildeverse::DataSaver).to receive(:new).with(data).and_call_original
    expect_any_instance_of(Tildeverse::DataSaver).to receive(:save_with_config)
    data.save_with_config
  end

  # Call #user
  # Set new information about a user
  # Call #clear
  # Call #user (which will implicitly re-read from file if data empty)
  # Information should NOT have been saved
  it '#clear' do
    data = instance
    user = data.user('nossidge').first
    old_tags = user.tags
    new_tags = %w[bar foo]
    user.tags = new_tags
    expect(user.tags).to eq new_tags
    data.clear
    user = data.user('nossidge').first
    expect(user.tags).to eq old_tags
  end
end
