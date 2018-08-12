#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::DataSaver' do

  # Same info as Config class, but not tied to a file on the system.
  let(:config_struct) do
    Struct.new(
      :update_type,
      :update_frequency,
      :generate_html,
      :updated_on
    ) do
      def generate_html?; generate_html; end
      def update; nil; end
    end
  end

  let(:config) do
    config_struct.new('scrape', 'week', false, '2018-06-08')
  end

  let(:instance) do
    Tildeverse::Data.new(config)
  end

  ##############################################################################

  describe '#save' do
    it 'should save to file and be loaded back' do
      data = instance
      user = data.user('nossidge').first
      old_tags = user.tags
      new_tags = %w[bar foo]
      user.tags = new_tags
      expect(user.tags).to eq new_tags
      data.save
      user = data.user('nossidge').first
      expect(user.tags).to eq new_tags
      user.tags = old_tags
      data.save
      user = data.user('nossidge').first
      expect(user.tags).to eq old_tags
    end
  end

  describe '#save_website' do
    it 'should update the users JSON file, and the static web files' do
      files_to_update = Tildeverse::Files.files_to_copy.map do |f|
        Tildeverse::Files.dir_output + f
      end
      files_to_update << Tildeverse::Files.output_json_users

      # Get hash of files to modified times.
      mod_times_hash = ->(files) do
        {}.tap do |hash|
          files.each do |f|
            hash[f] = f.mtime rescue Time.at(0)
          end
        end
      end
      old_mod_times = mod_times_hash.call(files_to_update)
      instance.save_website
      new_mod_times = mod_times_hash.call(files_to_update)

      # Make sure the mod times are newer.
      files_to_update.each do |f|
        expect(old_mod_times[f]).to be < new_mod_times[f]
      end
    end
  end

  describe '#save_with_config' do
    it 'should always call #save' do
      save_website = true
      config = config_struct.new('scrape', 'week', save_website, '2018-06-08')
      data = Tildeverse::Data.new(config)
      saver = Tildeverse::DataSaver.new(data)
      expect(saver).to receive(:save)
      expect(saver).to receive(:save_website)
      saver.save_with_config
    end

    it 'Should only call #save_website if the config value is set' do
      save_website = false
      config = config_struct.new('scrape', 'week', save_website, '2018-06-08')
      data = Tildeverse::Data.new(config)
      saver = Tildeverse::DataSaver.new(data)
      expect(saver).to receive(:save)
      expect(saver).to_not receive(:save_website)
      saver.save_with_config
    end
  end
end
