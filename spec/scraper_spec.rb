#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Scraper' do
  #
  # Implement the bare minimum to quack like a Config object
  let(:config) do
    double('Config', :authorised? => true)
  end

  # Implement the bare minimum to quack like a Data object
  let(:data) do
    double('Data', :config => config, :save_with_config => nil).tap do |dbl|
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
    double('Site', :scrape => nil, :name => 'site.foo')
  end

  ##############################################################################

  let(:scraper) { Tildeverse::Scraper.new(data) }
  let(:result) { scraper.scrape }

  describe '#scrape' do
    it 'should correctly run if all necessary methods are available' do
      expect{ result }.to_not raise_error
      data.users.each do |user|
        expect(user.date_modified).to eq Tildeverse::TildeDate.new(nil)
      end
    end

    it 'should raise error if user not authorised by config' do
      allow(data.config).to receive(:authorised?).and_return(false)
      expect { result }.to raise_error(Tildeverse::Error::DeniedByConfig)
    end
  end

  describe '#update_mod_dates' do
    let(:mod_date) { '1984-01-01' }

    it 'should update the modified date if necessary' do
      mod_dates = Tildeverse::ModifiedDates.new
      allow(mod_dates).to receive(:for_user).and_return(mod_date)
      scraper.send(:update_mod_dates, mod_dates)
      data.users.each do |user|
        expect(user.date_modified).to eq Tildeverse::TildeDate.new(mod_date)
      end
    end
  end
end
