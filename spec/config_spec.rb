#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Config' do

  def temp_file
    Tildeverse::Files.dir_root + 'config/temp_config.yml'
  end

  def kill_temp_file
    File.delete(temp_file) if File.exist?(temp_file)
  end

  let(:terror) { Tildeverse::Error }

  let(:instance) do
    Tildeverse::Config.new(temp_file)
  end

  let(:default_values_hash) do
    {
      authorised_users: [],
      update_type:      'fetch',
      update_frequency: 'day',
      generate_html:    false,
      updated_on:       Date.new(1970, 1, 1)
    }
  end

  after(:each) do
    kill_temp_file
  end

  ##############################################################################

  describe '#new' do
    it 'should correctly instantiate using default file location' do
      config = Tildeverse::Config.new
      expect(config.class).to eq Tildeverse::Config
      expect(config.filepath).to eq Tildeverse::Files.config_yml
    end

    it 'should correctly instantiate using file passed as a param' do
      config = Tildeverse::Config.new(temp_file)
      expect(config.filepath).to eq temp_file

      # Make sure the options match the defaults
      default_values_hash.each do |k, v|
        expect(config.send(k)).to eq v
      end
    end
  end

  describe '#default_values' do
    it 'should use sensible default values' do
      config = Tildeverse::Config.new(temp_file)
      dv = config.send(:default_values)
      expect(dv).to eq default_values_hash
    end
  end

  ##############################################################################

  # Given valid and invalid data, confirm that the block raises or
  #   doesn't raise the exception 'exception'
  def test_raise_error(valid, invalid, exception, &code)
    valid.each do |i|
      expect { code.call(i) }.not_to raise_error
    end
    invalid.each do |i|
      expect { code.call(i) }.to raise_error(exception)
    end
  end

  # Only stipulation is that '#to_s' must be implemented.
  describe '#authorised_users=' do
    let(:no_to_s) do
      Class.new do
        undef :to_s
      end
    end

    it 'should validate to String array' do
      # Updating an attribute calls '#save' automatically, which
      # raises its own 'Error::DeniedByConfig', so disable it for now.
      allow(instance).to receive(:authorised?).and_return(true)

      valid = [%w[paul joe], ['paul', :joe], 'paul', 123, nil]
      invalid = [no_to_s.new]
      test_raise_error(valid, invalid, terror::AuthorisedUsersError) do |i|
        instance.send(:validate_authorised_users, i)
      end
      test_raise_error(valid, invalid, terror::AuthorisedUsersError) do |i|
        instance.authorised_users = i
      end
    end
  end

  describe '#update_type=' do
    it 'should validate from array: scrape fetch' do
      valid = %w[scrape fetch]
      invalid = [123, nil, Integer, true, 'always', 'day', 'week', 'month']
      test_raise_error(valid, invalid, terror::UpdateTypeError) do |i|
        instance.send(:validate_update_type, i)
      end
      test_raise_error(valid, invalid, terror::UpdateTypeError) do |i|
        instance.update_type = i
      end
    end
  end

  describe '#update_frequency=' do
    it 'should validate from array: always day week month' do
      valid = %w[always day week month]
      invalid = [123, nil, Integer, true, 'scrape', 'fetch']
      test_raise_error(valid, invalid, terror::UpdateFrequencyError) do |i|
        instance.send(:validate_update_frequency, i)
      end
      test_raise_error(valid, invalid, terror::UpdateFrequencyError) do |i|
        instance.update_frequency, = i
      end
    end
  end

  describe '#generate_html=' do
    it 'should validate from array: true false' do
      valid = [true, false]
      invalid = [123, nil, Integer, 'scrape', 'always']
      test_raise_error(valid, invalid, terror::GenerateHtmlError) do |i|
        instance.send(:validate_generate_html, i)
      end
      test_raise_error(valid, invalid, terror::GenerateHtmlError) do |i|
        instance.generate_html = i
      end
    end
  end

  ##############################################################################

  describe '#update' do
    it "should use today's date" do
      config = Tildeverse::Config.new(temp_file)
      expect(config.updated_on).to eq default_values_hash[:updated_on]
      config.update
      expect(config.updated_on).to eq Date.today

      # Create 2nd instance with same save file
      # Should be same date
      config = Tildeverse::Config.new(temp_file)
      expect(config.updated_on).to eq Date.today
    end
  end

  ##############################################################################

  describe "#update_required?" do
    it "should work correctly when update_frequency = 'always'" do
      config = Tildeverse::Config.new(temp_file)
      config.update_frequency = 'always'
      allow(config).to receive(:updated_on).and_return(Date.today + 1)
      expect(config.update_required?).to eq true
      allow(config).to receive(:updated_on).and_return(Date.today)
      expect(config.update_required?).to eq true
      allow(config).to receive(:updated_on).and_return(Date.today - 1)
      expect(config.update_required?).to eq true
    end

    it "should work correctly when update_frequency = 'day'" do
      config = Tildeverse::Config.new(temp_file)
      config.update_frequency = 'day'
      allow(config).to receive(:updated_on).and_return(Date.today + 1)
      expect(config.update_required?).to eq false
      allow(config).to receive(:updated_on).and_return(Date.today)
      expect(config.update_required?).to eq false
      allow(config).to receive(:updated_on).and_return(Date.today - 1)
      expect(config.update_required?).to eq true
    end

    it "should work correctly when update_frequency = 'week'" do
      config = Tildeverse::Config.new(temp_file)
      config.update_frequency = 'week'

      # Test with today's date, changing '#updated_on' date
      past   = Date.today - 50
      future = Date.today + 50
      (past..future).each do |date|
        allow(config).to receive(:updated_on).and_return(date)
        mon_date = Date.today - Date.today.cwday + 1
        sun_date = mon_date + 6
        week_range = (mon_date..sun_date)
        should_be = !week_range.include?(date)
        expect(config.update_required?).to eq should_be
      end

      # Test boundaries using explicit values, and a variable '#date_today'
      date_mon = Date.new(2018, 6, 18)
      date_sun = Date.new(2018, 6, 24)
      (date_mon..date_sun).each do |date|
        allow(config).to receive(:date_today).and_return(date)
        allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 16))
        expect(config.update_required?).to eq true
        allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 17))
        expect(config.update_required?).to eq true
        allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 18))
        expect(config.update_required?).to eq false
        allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 19))
        expect(config.update_required?).to eq false
      end
    end

    it "should work correctly when update_frequency = 'month'" do
      config = Tildeverse::Config.new(temp_file)
      config.update_frequency = 'month'

      allow(config).to receive(:date_today).and_return(Date.new(2018, 6, 16))
      allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 16))
      expect(config.update_required?).to eq false
      allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 1))
      expect(config.update_required?).to eq false
      allow(config).to receive(:updated_on).and_return(Date.new(2018, 5, 31))
      expect(config.update_required?).to eq true
      allow(config).to receive(:updated_on).and_return(Date.new(2018, 5, 16))
      expect(config.update_required?).to eq true
      allow(config).to receive(:updated_on).and_return(Date.new(2017, 6, 16))
      expect(config.update_required?).to eq true
      allow(config).to receive(:updated_on).and_return(Date.new(2017, 10, 1))
      expect(config.update_required?).to eq true

      # If '#updated_on' is in the future, wait for that date
      allow(config).to receive(:updated_on).and_return(Date.new(2020, 6, 16))
      expect(config.update_required?).to eq false
      allow(config).to receive(:updated_on).and_return(Date.new(2018, 6, 17))
      expect(config.update_required?).to eq false
      allow(config).to receive(:updated_on).and_return(Date.new(2018, 7, 1))
      expect(config.update_required?).to eq false
    end

    it 'should error when update_frequency is invalid' do
      config = Tildeverse::Config.new(temp_file)
      config.instance_variable_set(:@update_frequency, 'foo')
      expect { config.update_required? }.to raise_error(ArgumentError)
    end
  end

  ##############################################################################

  describe '#authorised?' do
    let(:config) { Tildeverse::Config.new(temp_file) }

    it 'should correctly compare logged-in user with @authorised_users' do
      # '#save' raises its own 'Error::DeniedByConfig', so disable it for now.
      allow(config).to receive(:save)

      config.authorised_users = Etc.getlogin
      expect(config.authorised?).to eq true
      expect(config.authorised?('invalid_user')).to eq false

      config.authorised_users = 'user_1'
      expect(config.authorised?('user_1')).to eq true
      expect(config.authorised?('invalid_user')).to eq false

      config.authorised_users = %w[user_1 user_2]
      expect(config.authorised?('user_1')).to eq true
      expect(config.authorised?('user_2')).to eq true
      expect(config.authorised?('invalid_user')).to eq false

      config.authorised_users << Etc.getlogin
      expect(config.authorised?).to eq true
      expect(config.authorised?('user_1')).to eq true
      expect(config.authorised?('user_2')).to eq true
      expect(config.authorised?('invalid_user')).to eq false
    end

    it 'should return true when @authorised_users = []' do
      config.authorised_users = []
      expect(config.authorised?).to eq true
      expect(config.authorised?('invalid_user')).to eq true
    end
  end
end
