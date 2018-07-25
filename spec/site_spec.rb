#!/usr/bin/env ruby

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
    it 'should be an instance of the correct Serializer class' do
      instances.each do |obj|
        expect(obj.serialize).to be_a Tildeverse::SiteSerializer
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
        end.to raise_error(NotImplementedError)
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
        end.to raise_error(NotImplementedError)
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

  it '#scrape' do
    # expect('TODO').to be 'actually done'
  end
end
