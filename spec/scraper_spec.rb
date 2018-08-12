#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Scraper' do

  # Implement the bare minimum to quack like a Data object
  def data_duck
    Class.new do
      def save_with_config
        # Do nothing
      end

      def sites
        3.times.map { site_duck.new }
      end

      def users
        3.times.map do |i|
          i = Tildeverse::User.new(site: site_duck.new, name: i.to_s)
        end
      end

      private

      # Implement the bare minimum to quack like a Site object
      def site_duck
        Class.new do
          def scrape
            # Do nothing
          end
          def name
            # Do nothing
          end
        end
      end
    end
  end

  describe '#scrape' do
    it 'should correctly run if all necessary methods are available' do
      data = data_duck.new
      scraper = Tildeverse::Scraper.new(data)
      expect{ scraper.scrape }.to_not raise_error
    end
  end
end
