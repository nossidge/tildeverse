#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::ExceptionSuppressor' do
  describe '#new' do
    it 'should correctly create an instance' do
      [
        'foo',
        123,
        ['foo', 123],
        URI('mailto:foo@example.com'),
        Tildeverse::Error::OfflineURIError,
        nil
      ].each do |args|
        obj = Tildeverse::ExceptionSuppressor.new(*args)
        expect(obj.to_a).to eq [*args]
      end
    end
  end

  describe '#handle' do
    it 'should correctly suppress specified exceptions' do
      error = ZeroDivisionError
      block = proc { 1 / 0 }

      supressor = Tildeverse::ExceptionSuppressor.new(error)
      expect { block.call }.to raise_error(error)

      expect do
        supressor.handle(ArgumentError) { block.call }
      end.to raise_error(error)

      expect do
        supressor.handle(error) { block.call }
      end.not_to raise_error
    end
  end

  describe 'SimpleDelegator array stuff' do
    it 'should both be equivalent' do
      supressor1 = Tildeverse::ExceptionSuppressor.new(ZeroDivisionError)

      supressor2 = Tildeverse::ExceptionSuppressor.new
      supressor2 << ZeroDivisionError

      expect(supressor1).to eq supressor2
    end
  end
end
