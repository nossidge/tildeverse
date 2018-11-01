#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::UserSerializer' do
  let(:example_data) do
    site_struct = Struct.new(:name) do
      def ==(o)
        name == o.name
      end
    end
    site = site_struct.new('example.com')
    {
      site:           site,
      name:           'paul',
      date_online:    Tildeverse::TildeDate.new('2016-01-02'),
      date_offline:   Tildeverse::TildeDate.new('2018-06-10'),
      date_modified:  Tildeverse::TildeDate.new('2017-02-09'),
      date_tagged:    Tildeverse::TildeDate.new('2017-03-25'),
      tags:           %w[foo bar baz]
    }
  end

  let(:instance) do
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
        date_online:    example_data[:date_online].to_s,
        date_offline:   example_data[:date_offline].to_s,
        date_modified:  example_data[:date_modified].to_s,
        date_tagged:    example_data[:date_tagged].to_s,
        tags:           example_data[:tags].join(','),
        online:         false
      }.to_s)
    end
  end

  describe '#for_tildeverse_json' do
    it 'should correctly serialise to hash' do
      user = instance
      serializer = Tildeverse::UserSerializer.new(user)
      data = serializer.for_tildeverse_json
      expect(data).to be_a Hash
      expect(data[:tagged]).to eq example_data[:date_tagged]
      expect(data[:tags]).to eq example_data[:tags]
      expect(data[:time]).to eq example_data[:date_modified]
      expect(data[:junk]).to be_nil
    end
  end

  describe '#to_a' do
    it 'should correctly serialise to array' do
      user = instance
      serializer = Tildeverse::UserSerializer.new(user)
      data = serializer.to_a
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
      expected_contents[-2] = Date.today
      data = serializer.to_a
      expect(data).to eq expected_contents
    end
  end
end
