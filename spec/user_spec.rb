#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::User' do
  def example_data
    site_struct = Struct.new(:name) do
      def uri
        @uri ||= Tildeverse::TildeSiteURI.new('http://example.com')
      end
      def ==(o)
        name == o.name
      end
    end
    {
      site:           site_struct.new('example.com'),
      name:           'paul',
      date_online:    Date.new(2016, 1, 2),
      date_offline:   Date.new(2018, 6, 10),
      date_modified:  Date.new(2017, 2, 9),
      date_tagged:    Date.new(2017, 3, 25),
      tags:           %w[foo bar baz]
    }
  end

  def instance
    Tildeverse::User.new(example_data)
  end

  ##############################################################################

  describe '#new' do
    it 'should correctly apply the input parameters hash' do
      user = instance
      example_data.each do |k, v|
        expect(user.send(k)).to eq v
      end
      expect(user.site.name).to eq 'example.com'
    end

    it 'should correctly apply the defaults to unspecified parameters' do
      user = Tildeverse::User.new(site: 'site.foo', name: 'site_foo')
      example_data.each do |k, v|
        next if %i[site name].include?(k)

        # Defaults are in private classes named in the format 'default_ATTR'
        default = user.send("default_#{k}")
        expect(user.send(k)).to eq default
      end
      expect(user.site).to eq 'site.foo'
      expect(user.name).to eq 'site_foo'
    end

    it 'should fail without necessary parameters' do
      expect do
        Tildeverse::User.new
      end.to raise_error(ArgumentError)

      expect do
        Tildeverse::User.new(site: 'site.foo')
      end.to raise_error(ArgumentError)

      expect do
        Tildeverse::User.new(name: 'site_foo')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#serialize' do
    it 'should correctly serialize using UserSerializer' do
      serializer = instance.serialize
      expect(serializer).to be_a Tildeverse::UserSerializer
    end
  end

  describe '#date_offline=' do
    it 'should overwrite the attribute with a new value' do
      user = instance
      old_value = user.date_offline
      new_value = 'foo'

      user.date_offline = new_value
      expect(user.date_offline).to eq new_value

      user = instance
      expect(user.date_offline).to eq old_value
    end
  end

  describe '#date_modified=' do
    it 'should overwrite the attribute with a new value' do
      user = instance
      old_value = user.date_modified
      new_value = 'foo'

      user.date_modified = new_value
      expect(user.date_modified).to eq new_value

      user = instance
      expect(user.date_modified).to eq old_value
    end
  end

  describe '#tags=' do
    it 'should reset the tags array to a new value' do
      user = instance
      old_tags = user.tags
      new_tags = %w[bar foo]

      user.tags = new_tags
      expect(user.tags).to eq new_tags
      expect(user.date_tagged).to eq Date.today.to_s

      user = instance
      expect(user.tags).to eq old_tags
    end
  end

  describe '#online?' do
    it 'should return a boolean value' do
      user = instance
      expect(user.online?).to eq false
    end
  end

  describe '#homepage' do
    it 'should delegate the method to a TildeSiteURI object' do
      user = instance
      expect(user.site.uri).to receive(:homepage).with(user.name)
      user.homepage
    end
  end

  describe '#email' do
    it 'should delegate the method to a TildeSiteURI object' do
      user = instance
      expect(user.site.uri).to receive(:email).with(user.name)
      user.email
    end
  end
end
