#!/usr/bin/env ruby

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
  end

  describe '#serialize' do
    it 'should correctly serialize using UserSerializer' do
      serializer = instance.serialize
      expect(serializer).to be_a Tildeverse::UserSerializer
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
