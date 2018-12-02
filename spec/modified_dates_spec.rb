#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::ModifiedDates' do

  let(:file_contents) do
    filepath = Tildeverse::Files.dir_root + 'seed' + 'modified_dates.html'
    Tildeverse::Files.read_utf8(filepath)
  end

  let(:remote_dbl) do
    double('RemoteResource').tap do |dbl|
      allow(dbl).to receive(:get).and_return(file_contents)
    end
  end

  let(:instance) do
    Tildeverse::ModifiedDates.new.tap do |obj|
      allow(obj).to receive(:remote).and_return(remote_dbl)
    end
  end

  ##############################################################################

  describe '#get' do
    it 'should return a hash of hashes of dates' do
      result = instance.get

      expect(result).to be_a Hash
      expect(result['tilde.town']).to be_a Hash
      expect(result['tilde.town']['nossidge']).to be_a Date

      only_values = result.values.map(&:values).flatten
      only_values.each do |value|
        expect(value).to be_a Date
      end
    end
  end

  describe '#for_user' do
    it 'should return a result given valid input' do
      [
        ['tilde.town', 'nossidge', '2017-04-02'],
        ['pebble.ink', 'imt',      '2015-01-09']
      ].each do |site, user, date|
        result = instance.for_user(site, user)
        expect(result).to eq Date.parse(date)
      end
    end

    it 'should return nil given invalid input' do
      [
        ['pebble.ink', 'foobarbazfring'],
        ['example.com', 'imt'],
        ['', ''],
        ['pebble.ink', nil],
        [nil, nil]
      ].each do |site, user|
        result = instance.for_user(site, user)
        expect(result).to be_nil
      end
    end
  end

  describe '#remote' do
    it 'should return a RemoteResource object' do
      instance = Tildeverse::ModifiedDates.new
      expect(instance.send(:remote)).to be_a Tildeverse::RemoteResource
    end
  end
end
