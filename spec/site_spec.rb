#!/usr/bin/env ruby

describe 'Tildeverse::Site' do
  valid_params = {
    name: 'example.com',
    url_root: 'http://www.example.com',
    url_list: 'http://www.example.com/userlist.json',
    homepage_format: 'http://www.example.com/~USER/'
  }

  ##############################################################################

  describe '#new' do
    it 'should not be initialised directly, as class is abstract' do
      expect { Tildeverse::Site.new }.to raise_error(NotImplementedError)
    end

    it "should reject if @name not specified" do
      params = valid_params.dup.tap { |hash| hash.delete(:name) }
      expect do
        Class.new(Tildeverse::Site).new(params)
      end.to raise_error(ArgumentError, 'missing keyword: name')
    end

    it "should reject if @url_root not specified" do
      params = valid_params.dup.tap { |hash| hash.delete(:url_root) }
      expect do
        Class.new(Tildeverse::Site).new(params)
      end.to raise_error(ArgumentError, 'missing keyword: url_root')
    end

    it "should reject if @homepage_format not specified" do
      params = valid_params.dup.tap { |hash| hash.delete(:homepage_format) }
      expect do
        Class.new(Tildeverse::Site).new(params)
      end.to raise_error(ArgumentError, 'missing keyword: homepage_format')
    end

    it "if empty, @uri#url_list should use the value of @uri#url_root" do
      params = valid_params.dup.tap { |hash| hash.delete(:url_list) }
      obj = Class.new(Tildeverse::Site).new(params)
      expect(obj.uri.url_list).to eq obj.uri.url_root
    end

    it 'should correctly allow inheritance' do
      expect do
        Class.new(Tildeverse::Site).new(valid_params)
      end.not_to raise_error
    end
  end

  ##############################################################################

  describe '#serialize' do
    it 'should be an instance of the correct Serializer class' do
      obj = Class.new(Tildeverse::Site).new(valid_params)
      serializer = obj.serialize
      expect(serializer).to be_a Tildeverse::SiteSerializer
    end
  end

  ##############################################################################

  describe 'abstract_method #scrape_users' do
    class SiteImplementingScrapeUsers < Tildeverse::Site
      def scrape_users; 'foo'; end
    end

    it 'should fail if not implemented in the inherited class' do
      msg = /#scrape_users is not implemented/
      obj = Class.new(Tildeverse::Site).new(valid_params)
      expect do
        obj.scrape_users
      end.to raise_error(NotImplementedError, msg)
    end

    it 'should correctly allow inheritance when implementing the method' do
      obj = SiteImplementingScrapeUsers.new(valid_params)
      expect do
        obj.scrape_users
      end.not_to raise_error
    end
  end

  ##############################################################################

  describe 'abstract_method #online?' do
    class SiteImplementingOnline < Tildeverse::Site
      def online?; 'foo'; end
    end

    it 'should fail if not implemented in the inherited class' do
      msg = '#online? class method is not implemented'
      obj = Class.new(Tildeverse::Site).new(valid_params)
      expect do
        obj.online?
      end.to raise_error(NotImplementedError, msg)
    end

    it 'should correctly allow inheritance when implementing the method' do
      obj = SiteImplementingOnline.new(valid_params)
      expect do
        obj.online?
      end.not_to raise_error
    end
  end

  ##############################################################################

  describe '#user(user_name)' do
    class SiteImplementingAllMethods < Tildeverse::Site
      def scrape_users; 'foo'; end
      def online?; 'foo'; end
    end

    it 'should return nil on empty user list' do
      obj = SiteImplementingAllMethods.new(valid_params)
      expect(obj.user('nossidge')).to be nil
    end

    it 'should return nil on incorrect user input' do
      params = valid_params.dup.tap { |hash| hash[:name] = 'tilde.town'}
      obj = SiteImplementingAllMethods.new(params)
      expect(obj.user('foobar_not_a_valid_user')).to be nil
    end

    it 'should return correct user if given valid inputs' do
      params = valid_params.dup.tap { |hash| hash[:name] = 'tilde.town'}
      obj = SiteImplementingAllMethods.new(params)
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
