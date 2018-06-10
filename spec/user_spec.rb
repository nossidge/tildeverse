#!/usr/bin/env ruby

describe 'Tildeverse::User' do
  SiteStruct = Struct.new(:name) do
    def ==(o)
      name == o.name
    end
  end

  def example_data
    site = SiteStruct.new('example.com')
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

  it '#url' do
    user = instance
    expect(user.site).to receive(:user_page).with(user.name)
    user.url
  end

  it '#email' do
    user = instance
    expect(user.site).to receive(:user_email).with(user.name)
    user.email
  end

  ##############################################################################

  it '#to_s' do
    user = instance
    data = user.to_s
    expect(data).to be_a String
    expect(data).to eq ({
      site:           example_data[:site].name,
      name:           example_data[:name],
      date_online:    example_data[:date_online],
      date_offline:   example_data[:date_offline],
      date_modified:  example_data[:date_modified],
      date_tagged:    example_data[:date_tagged],
      tags:           example_data[:tags].join(','),
      online:         false
    }.to_s)
  end

  it '#serialize_output' do
    user = instance
    data = user.serialize_output
    expect(data).to be_a Hash
    expect(data[:tagged]).to eq example_data[:date_tagged]
    expect(data[:tags]).to eq example_data[:tags]
    expect(data[:time]).to eq example_data[:date_modified]
    expect(data[:junk]).to be_nil
  end

  it '#serialize_to_txt_array' do
    user = instance
    data = user.serialize_to_txt_array
    expect(data).to be_an Array

    expected_contents = [
      example_data[:site].name,
      example_data[:name],
      example_data[:date_online],
      example_data[:date_offline],
      example_data[:date_modified],
      example_data[:date_tagged],
      example_data[:tags].join(',')
    ]
    expect(data).to eq expected_contents

    # With empty tags, it should use '-'
    user.tags = []
    expected_contents[-1] = '-'
    expected_contents[-2] = Date.today.to_s
    data = user.serialize_to_txt_array
    expect(data).to eq expected_contents
  end
end
