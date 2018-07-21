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

  describe '#serialize' do
    it 'should be a Tildeverse::DataSerializer' do
      serializer = instance.serialize
      expect(serializer).to be_a Tildeverse::DataSerializer
    end
  end

  describe '#config' do
    it 'should be the same as the #initialize parameter' do
      expect(instance.config).to eq config
    end
  end

  describe '#sites' do
    it 'should include one object of each Sites class' do
      sites = instance.sites.map(&:class)
      expect(sites).to eq Tildeverse::Sites.classes
    end
  end

  describe '#site' do
    it 'should return the correct site, given the site name' do
      site = instance.site('pebble.ink')
      expect(site).to be_a Tildeverse::Sites::PebbleInk
      site = instance.site('tilde.town')
      expect(site).to be_a Tildeverse::Sites::TildeTown
    end

    it 'should return nil, given an invalid site name' do
      site = instance.site('foo-bar.example')
      expect(site).to be nil
    end
  end

  describe '#users' do
    it 'should return an array of User objects' do
      users = instance.users
      expect(users).to all be_a Tildeverse::User
    end
  end

  describe '#user' do
    it 'should return an array of User objects, given a user name' do
      %w[nossidge imt foobar_no_name].each do |username|
        users = instance.user(username)
        expect(users).to all be_a Tildeverse::User
        names = users.map(&:name)
        expect(names).to all eq username
      end
    end
  end

  describe '#save' do
    it 'should delegate the method to a DataSaver object' do
      expect(Tildeverse::DataSaver).to(
        receive(:new).with(instance).and_call_original
      )
      expect_any_instance_of(Tildeverse::DataSaver).to receive(:save)
      instance.save
    end
  end

  describe '#save_website' do
    it 'should delegate the method to a DataSaver object' do
      expect(Tildeverse::DataSaver).to(
        receive(:new).with(instance).and_call_original
      )
      expect_any_instance_of(Tildeverse::DataSaver).to receive(:save_website)
      instance.save_website
    end
  end

  describe '#save_with_config' do
    it 'should delegate the method to a DataSaver object' do
      expect(Tildeverse::DataSaver).to(
        receive(:new).with(instance).and_call_original
      )
      expect_any_instance_of(Tildeverse::DataSaver).to receive(:save_with_config)
      instance.save_with_config
    end
  end

  # Call #user
  # Set new information about a user
  # Call #clear
  # Call #user (which will implicitly re-read from file if data empty)
  # Information should NOT have been saved
  describe '#clear' do
    it 'should correctly clear the underlying data hash object' do
      user = instance.user('nossidge').first
      old_tags = user.tags
      new_tags = %w[bar foo]
      user.tags = new_tags
      expect(user.tags).to eq new_tags
      instance.clear
      user = instance.user('nossidge').first
      expect(user.tags).to eq old_tags
    end
  end
end
