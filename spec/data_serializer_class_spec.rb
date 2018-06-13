#!/usr/bin/env ruby

require_relative '../lib/tildeverse/data_serializer_class'

describe 'Tildeverse::DataSerializerClass' do
  def data
    Tildeverse.data
  end
  def sites
    [Tildeverse::Sites::PebbleInk.new, Tildeverse::Sites::SkylabOrg.new]
  end
  def users
    Tildeverse.user('imt')
  end
  def data_serializer_class
    Tildeverse::DataSerializerClass.new(data)
  end

  describe '#serialize_users(users)' do
    it 'should duplicate the output of data#serialize_users(users)' do
      results = data_serializer_class.serialize_users(users)
      expect(results).to eq data.serialize_users(users)
    end
  end

  describe '#serialize_sites(sites)' do
    it 'should duplicate the output of data#serialize_sites(sites)' do
      results = data_serializer_class.serialize_sites(sites)
      expect(results).to eq data.serialize_sites(sites)
    end
  end

  describe '#serialize_all_sites' do
    it 'should duplicate the output of data#serialize_all_sites' do
      results = data_serializer_class.serialize_all_sites
      expect(results).to eq data.serialize_all_sites
    end
  end

  describe '#serialize_tildeverse_json' do
    it 'should duplicate the output of data#serialize_tildeverse_json' do
      results = data_serializer_class.serialize_tildeverse_json
      expect(results).to eq data.serialize_tildeverse_json
    end
  end

  describe '#serialize_users_json' do
    it 'should duplicate the output of data#serialize_users_json' do
      results = data_serializer_class.serialize_users_json
      expect(results).to eq data.serialize_users_json
    end
  end

  describe '#serialize_tildeverse_txt' do
    it 'should duplicate the output of data#serialize_tildeverse_txt' do
      results = data_serializer_class.serialize_tildeverse_txt
      expect(results).to eq data.serialize_tildeverse_txt
    end
  end
end
