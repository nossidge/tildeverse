#!/usr/bin/env ruby

describe 'Tildeverse::Fetcher' do

  # Implement the bare minimum to quack like a Data object
  def data_duck
    Class.new do
      def save_with_config; end
      def clear; end
    end
  end

  describe '#fetch' do
    it 'should correctly run if all necessary methods are available' do
      data = data_duck.new
      fetcher = Tildeverse::Fetcher.new(data)
      expect{ fetcher.fetch }.to_not raise_error
    end
  end
end
