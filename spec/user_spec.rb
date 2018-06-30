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
    site = site_struct.new('example.com')
    {
      site:           site,
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

  it '#new' do
    user = instance
    example_data.each do |k, v|
      expect(user.send(k)).to eq v
    end
    expect(user.site.name).to eq 'example.com'
  end

  it '#serialize' do
    serializer = instance.serialize
    expect(serializer).to be_a Tildeverse::UserSerializer
  end

  it '#tags=' do
    user = instance
    old_tags = user.tags
    new_tags = %w[bar foo]

    user.tags = new_tags
    expect(user.tags).to eq new_tags
    expect(user.date_tagged).to eq Date.today.to_s

    user = instance
    expect(user.tags).to eq old_tags
  end

  it '#online?' do
    user = instance
    expect(user.online?).to eq false
  end

  it '#homepage' do
    user = instance
    expect(user.site.uri).to receive(:homepage).with(user.name)
    user.homepage
  end

  it '#email' do
    user = instance
    expect(user.site.uri).to receive(:email).with(user.name)
    user.email
  end
end
