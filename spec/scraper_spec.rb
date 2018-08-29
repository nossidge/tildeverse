#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Scraper' do

  # Implement the bare minimum to quack like a Data object
  let(:data_duck) do
    double('Data', :save_with_config => nil).tap do |dbl|
      allow(dbl).to receive(:sites).and_return(
        3.times.map { site_duck }
      )
      allow(dbl).to receive(:users).and_return(
        3.times.map { |i| Tildeverse::User.new(site: site_duck, name: i.to_s) }
      )
    end
  end

  # Implement the bare minimum to quack like a Site object
  let(:site_duck) do
    double('Site', :scrape => nil, :name => nil)
  end

  describe '#scrape' do
    it 'should correctly run if all necessary methods are available' do
      data = data_duck
      scraper = Tildeverse::Scraper.new(data)
      expect{ scraper.scrape }.to_not raise_error
    end
  end
end
