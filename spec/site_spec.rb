#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Site' do
  let(:example_data) do
    {
      'https://tilde.town/~dan/users.json' => {
        name:             'tilde.town',
        url_root:         'https://tilde.town',
        url_list:         'https://tilde.town/~dan/users.json',
        homepage_format:  'https://tilde.town/~USER/'
      },
      'http://example.com' => {
        name:             'example.com',
        url_root:         'http://example.com',
        url_list:         'http://example.com',
        homepage_format:  'http://example.com/~USER/'
      }
    }
  end

  let(:example_uris) do
    example_data.keys.map do |uri|
      Tildeverse::TildeSiteURI.new(uri)
    end
  end

  let(:klass) do
    Class.new(Tildeverse::Site) do
      def scrape_users; 'foo'; end
      def online?; 'foo'; end
    end
  end

  let(:instances) do
    example_uris.map do |uri|
      klass.new(uri)
    end
  end

  ##############################################################################

  describe '#new' do
    it 'should allow inherited class to be instantiated' do
      example_uris.map do |uri|
        expect do
          klass.new(uri)
        end.not_to raise_error
      end
    end
  end

  ##############################################################################

  describe '#serialize' do
    it 'should be an instance of SiteSerializer' do
      instances.each do |obj|
        expect(obj.serialize).to be_a Tildeverse::SiteSerializer
      end
    end
  end

  describe '#to_s' do
    it 'should return a string' do
      instances.each do |obj|
        expect(obj.to_s).to be_a String
      end
    end
    it 'should delegate the method to the #serialize SiteSerializer' do
      instances.each do |obj|
        expect(obj.to_s).to eq obj.serialize.to_s
      end
    end
  end

  ##############################################################################

  describe 'abstract method #scrape_users' do
    it 'should fail if not implemented in the inherited class' do
      example_uris.map do |uri|
        obj = Class.new(Tildeverse::Site).new(uri)
        expect do
          obj.scrape_users
        end.to raise_error(Tildeverse::Error::AbstractMethodError)
      end
    end

    it 'should correctly allow inheritance when implementing the method' do
      example_uris.map do |uri|
        obj = klass.new(uri)
        expect do
          obj.scrape_users
        end.not_to raise_error
      end
    end
  end

  ##############################################################################

  describe 'abstract method #online?' do
    it 'should fail if not implemented in the inherited class' do
      example_uris.map do |uri|
        obj = Class.new(Tildeverse::Site).new(uri)
        expect do
          obj.online?
        end.to raise_error(Tildeverse::Error::AbstractMethodError)
      end
    end

    it 'should correctly allow inheritance when implementing the method' do
      example_uris.map do |uri|
        obj = klass.new(uri)
        expect do
          obj.online?
        end.not_to raise_error
      end
    end
  end

  ##############################################################################

  describe '#user(user_name)' do
    it 'should return nil on empty user list' do
      uri = Tildeverse::TildeSiteURI.new('http://example.com')
      obj = klass.new(uri)
      expect(obj.user('nossidge')).to be nil
    end

    it 'should return nil on incorrect user input' do
      uri = Tildeverse::TildeSiteURI.new('https://tilde.town/~dan/users.json')
      obj = klass.new(uri)
      expect(obj.user('foobar_not_a_valid_user')).to be nil
    end

    it 'should return correct user if given valid inputs' do
      uri = Tildeverse::TildeSiteURI.new('https://tilde.town/~dan/users.json')
      obj = klass.new(uri)
      user = obj.user('nossidge')
      expect(user).to be_a Tildeverse::User
      expect(user.name).to eq 'nossidge'
      expect(user.site).to eq obj
    end
  end

  ##############################################################################

  describe '#scrape' do
    include_context 'before_each__seed_the_data'

    it 'should correctly contact the site through HTTP' do
      pebble_ink = Tildeverse.site('pebble.ink')
      users_orig = pebble_ink.users.map(&:name)
      users_scraped = pebble_ink.scrape
      expect(users_scraped).to eq users_orig
    end

    # We won't really scrape from external HTML, just mock the results
    # Use 'pebble.ink' seed data as the example
    it 'should correctly scrape and merge the users' do

      # Get current users from the seed data
      users_orig = Tildeverse.site('pebble.ink').users.map(&:name)

      # Add and remove one user
      # We expect that the deleted 'imt' user will remain in the system
      users_mocked   = users_orig + ['foo'] - ['imt']
      users_expected = users_orig + ['foo']

      # Mock the memoized 'scrape_users_cache' to return the new list
      pebble_ink = Tildeverse.site('pebble.ink')
      allow(pebble_ink).to(
        receive(:scrape_users_cache).and_return(users_mocked)
      )

      # Perform the scrape
      pebble_ink.scrape
      users_now = Tildeverse.site('pebble.ink').users.map(&:name)

      # Confirm that the changes have been made
      expect(users_now).to eq users_expected.sort

      # Confirm that the deleted user is offline
      deleted_user = Tildeverse.site('pebble.ink').user('imt')
      expect(deleted_user.online?).to eq false

      # Confirm that the offline date is correct
      expect(deleted_user.date_offline).to eq Date.today
    end
  end

  ##############################################################################

  describe '#validate_usernames' do
    let(:site) { Tildeverse.site('pebble.ink') }

    it 'should not output error if array contains values' do
      expect do
        site.send(:validate_usernames) do
          %w[foo bar baz]
        end
      end.not_to raise_error
    end

    it 'should output error if array is empty' do
      expect do
        site.send(:validate_usernames) do
          []
        end
      end.to raise_error(Tildeverse::Error::NoUsersFoundError)
    end
  end
end
