#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Scraper' do
  let(:site_name) { 'site.foo' }

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
    double('Site', :scrape => nil, :name => site_name)
  end

  ##############################################################################

  let(:instance) { Tildeverse::Scraper.new(data_duck) }

  describe '#scrape' do
    it 'should correctly run if all necessary methods are available' do
      expect{ instance.scrape }.to_not raise_error
      data_duck.users.each do |user|
        expect(user.date_modified).to eq '-'
      end
    end
  end

  describe '#update_mod_dates' do
    let(:mod_date) { '1970-01-01' }

    it 'should update the modified date if necessary' do
      mod_dates = Tildeverse::ModifiedDates.new
      allow(mod_dates).to receive(:for_user).and_return(mod_date)
      instance.send(:update_mod_dates, mod_dates)
      data_duck.users.each do |user|
        expect(user.date_modified).to eq mod_date
      end
    end
  end
end
