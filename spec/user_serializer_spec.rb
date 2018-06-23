#!/usr/bin/env ruby

describe 'Tildeverse::UserSerializer' do
  def example_data
    site_struct = Struct.new(:name) do
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

  describe '#to_s' do
    it 'should correctly serialise to string' do
      user = instance
      serializer = Tildeverse::UserSerializer.new(user)
      data = serializer.to_s
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
  end

  describe '#serialize_output' do
    it 'should correctly serialise to hash' do
      user = instance
      serializer = Tildeverse::UserSerializer.new(user)
      data = serializer.serialize_output
      expect(data).to be_a Hash
      expect(data[:tagged]).to eq example_data[:date_tagged]
      expect(data[:tags]).to eq example_data[:tags]
      expect(data[:time]).to eq example_data[:date_modified]
      expect(data[:junk]).to be_nil
    end
  end

  describe '#serialize_to_txt_array' do
    it 'should correctly serialise to array' do
      user = instance
      serializer = Tildeverse::UserSerializer.new(user)
      data = serializer.serialize_to_txt_array
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
      data = serializer.serialize_to_txt_array
      expect(data).to eq expected_contents
    end
  end
end
