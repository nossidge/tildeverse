#!/usr/bin/env ruby

require_relative '../lib/tildeverse/user_serializer_class'

describe 'Tildeverse::UserSerializerClass' do
  def user
    Tildeverse.user('nossidge').first
  end
  def user_serializer_class
    Tildeverse::UserSerializerClass.new(user)
  end

  describe '#to_s' do
    it 'should duplicate the output of user#to_s' do
      results = user_serializer_class.to_s
      expect(results).to eq user.to_s
    end
  end

  describe '#serialize_output' do
    it 'should duplicate the output of user#serialize_output' do
      results = user_serializer_class.serialize_output
      expect(results).to eq user.serialize_output
    end
  end

  describe '#serialize_to_txt_array' do
    it 'should duplicate the output of user#serialize_to_txt_array' do
      results = user_serializer_class.serialize_to_txt_array
      expect(results).to eq user.serialize_to_txt_array
    end
  end
end
