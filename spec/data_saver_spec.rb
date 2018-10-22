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
      def authorised?; true; end
    end
  end

  let(:config) { config_struct.new('scrape', 'week', false, '2018-06-08') }
  let(:data)   { Tildeverse::Data.new(config) }
  let(:saver)  { Tildeverse::DataSaver.new(data) }

  ##############################################################################

  describe '#save' do
    it 'should save to file and be loaded back' do
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

    it 'should raise error if user not authorised by config' do
      allow(config).to receive(:authorised?).and_return(false)
      expect { data.save }.to raise_error(Tildeverse::Error::DeniedByConfig)
    end
  end

  describe '#save_website' do
    it 'should update the users JSON file, and the static web files' do
      files_to_update = Tildeverse::Files.files_to_copy.map do |f|
        Tildeverse::Files.dir_output + f
      end
      files_to_update << Tildeverse::Files.output_json_users

      # Kill the existing files.
      files_to_update.each do |f|
        f.delete if f.exist?
      end

      # Ensure the files do not exist.
      files_to_update.each do |f|
        expect(f.exist?).to be false
      end

      # Run the method to create the files.
      data.save_website

      # Ensure the files DO exist.
      files_to_update.each do |f|
        expect(f.exist?).to be true
      end
    end

    it 'should raise error if user not authorised by config' do
      allow(config).to receive(:authorised?).and_return(false)
      expect do
        data.save_website
      end.to raise_error(Tildeverse::Error::DeniedByConfig)
    end
  end

  describe '#save_with_config' do
    it 'should always call #save' do
      allow(config).to receive(:generate_html?).and_return(true)
      expect(saver).to receive(:save)
      expect(saver).to receive(:save_website)
      saver.save_with_config
    end

    it 'Should only call #save_website if the config value is set' do
      allow(config).to receive(:generate_html?).and_return(false)
      expect(saver).to receive(:save)
      expect(saver).to_not receive(:save_website)
      saver.save_with_config
    end

    it 'should raise error if user not authorised by config' do
      allow(config).to receive(:authorised?).and_return(false)
      expect do
        data.save_with_config
      end.to raise_error(Tildeverse::Error::DeniedByConfig)
    end
  end
end
