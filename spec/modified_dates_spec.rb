#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::ModifiedDates' do
  let (:instance) do
    @instance ||= Tildeverse::ModifiedDates.new
  end

  describe '#data' do
    it 'should return an array of hashes' do
      result = instance.data

      expect(result).to be_a Array
      expect(result.first).to be_a Hash

      expect(result.first[:site]).to_not be_nil
      expect(result.first[:user]).to_not be_nil
      expect(result.first[:date]).to_not be_nil
      expect(result.first[:junk]).to be_nil

      result.each do |i|
        expect do
          Time.strptime(i[:date], '%Y-%m-%d')
        end.to_not raise_error
      end
    end
  end

  describe '#for_user' do
    it 'should return a result given valid input' do
      [
        ['tilde.town', 'nossidge'],
        ['pebble.ink', 'imt']
      ].each do |i|
        result = instance.for_user(i.first, i.last)
        expect(result).to_not be_nil
      end
    end

    it 'should return nil given invalid input' do
      [
        ['pebble.ink', 'foobarbazfring'],
        ['example.com', 'imt'],
        ['', ''],
        ['pebble.ink', nil],
        [nil, nil]
      ].each do |i|
        result = instance.for_user(i.first, i.last)
        expect(result).to be_nil
      end
    end
  end
end
