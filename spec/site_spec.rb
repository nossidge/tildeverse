#!/usr/bin/env ruby

describe 'Tildeverse::Site' do
  valid_params = {
    name: 'example.com',
    root: 'http://www.example.com',
    resource: 'http://www.example.com/userlist.json',
    url_format_user: 'http://www.example.com/~USER/'
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

    it "should reject if @root not specified" do
      params = valid_params.dup.tap { |hash| hash.delete(:root) }
      expect do
        Class.new(Tildeverse::Site).new(params)
      end.to raise_error(ArgumentError, 'missing keyword: root')
    end

    it "should reject if @url_format_user not specified" do
      params = valid_params.dup.tap { |hash| hash.delete(:url_format_user) }
      expect do
        Class.new(Tildeverse::Site).new(params)
      end.to raise_error(ArgumentError, 'missing keyword: url_format_user')
    end

    it "if empty, @resource should use the value of @root" do
      params = valid_params.dup.tap { |hash| hash.delete(:resource) }
      obj = Class.new(Tildeverse::Site).new(params)
      expect(obj.resource).to eq obj.root
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

  describe '#user_page(user)' do
    it 'should fail if @url_format_user template is incorrect' do
      params = valid_params.dup
      params[:url_format_user] = 'http://www.example.com/~USfER/'
      obj = Class.new(Tildeverse::Site).new(params)
      msg  = "#url_format_user should be in the form eg: "
      msg += "http://www.example.com/~USER/"
      expect do
        obj.user_page('nossidge')
      end.to raise_error(ArgumentError, msg)
    end

    it 'should return correct URL if given valid inputs' do
      obj = Class.new(Tildeverse::Site).new(valid_params)
      %w[nossidge imt foobar_not_a_valid_user].each do |user_name|
        user_page = obj.user_page(user_name)
        desired = valid_params[:url_format_user].sub('USER', user_name)
        expect(user_page).to eq desired
      end
    end
  end

  ##############################################################################

  describe '#user_email(user)' do
    it 'should return correct email if given valid inputs' do
      obj = Class.new(Tildeverse::Site).new(valid_params)
      %w[nossidge imt foobar_not_a_valid_user].each do |user_name|
        user_email = obj.user_email(user_name)
        desired = user_name + '@' + valid_params[:name]
        expect(user_email).to eq desired
      end
    end
  end

  ##############################################################################

  it '#scrape' do
    # expect('TODO').to be 'actually done'
  end
end
