#!/usr/bin/env ruby

describe 'Tildeverse::Config' do

  def instance
    Tildeverse::Config.new(temp_file)
  end

  def temp_file
    Tildeverse::Files.dir_root + 'config/temp_config.yml'
  end

  def kill_temp_file
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def default_values_hash
    {
      update_type:      'fetch',
      update_frequency: 'day',
      generate_html:    false,
      updated_on:       Date.new(1970, 1, 1)
    }
  end

  after(:all) do
    kill_temp_file
  end

  ##############################################################################

  # There should be no trouble with default file location
  it '#new(default)' do
    config = Tildeverse::Config.new
    expect(config.class).to eq Tildeverse::Config
    expect(config.filepath).to eq Tildeverse::Files.config_yml
  end

  # There should be no trouble with default file location
  it '#new(temp_file)' do
    kill_temp_file
    config = Tildeverse::Config.new(temp_file)
    expect(config.filepath).to eq temp_file

    # Make sure the options match the defaults
    default_values_hash.each do |k, v|
      expect(config.send(k)).to eq v
    end
  end

  # The default values should be sensible
  it '#default_values' do
    kill_temp_file
    config = Tildeverse::Config.new(temp_file)
    dv = config.send(:default_values)
    expect(dv).to eq default_values_hash
  end

  ##############################################################################

  # Given valid and invalid data, confirm that the block raises or
  #   doesn't raise an ArgumentError
  def test_raise_error(valid, invalid, &code)
    valid.each do |i|
      expect { code.call(i) }.not_to raise_error
    end
    invalid.each do |i|
      expect { code.call(i) }.to raise_error(ArgumentError)
    end
  end

  it '#update_type=' do
    valid = %w[scrape fetch]
    invalid = [123, nil, Integer, true, 'always', 'day', 'week', 'month']
    test_raise_error(valid, invalid) do |i|
      instance.send(:validate_update_type, i)
    end
    test_raise_error(valid, invalid) do |i|
      instance.update_type = i
    end
  end

  it '#update_frequency=' do
    valid = %w[always day week month]
    invalid = [123, nil, Integer, true, 'scrape', 'fetch']
    test_raise_error(valid, invalid) do |i|
      instance.send(:validate_update_frequency, i)
    end
    test_raise_error(valid, invalid) do |i|
      instance.update_frequency, = i
    end
  end

  it '#generate_html=' do
    valid = [true, false]
    invalid = [123, nil, Integer, 'scrape', 'always']
    test_raise_error(valid, invalid) do |i|
      instance.send(:validate_generate_html, i)
    end
    test_raise_error(valid, invalid) do |i|
      instance.generate_html = i
    end
  end

  ##############################################################################

  # Make sure #update uses today's date
  it '#update' do
    kill_temp_file
    config = Tildeverse::Config.new(temp_file)
    expect(config.updated_on).to eq default_values_hash[:updated_on]
    config.update
    expect(config.updated_on).to eq Date.today

    # Create 2nd instance with same save file
    # Should be same date
    config = Tildeverse::Config.new(temp_file)
    expect(config.updated_on).to eq Date.today
  end

  ##############################################################################

  it "#update_required? <- update_frequency = 'always'" do
    kill_temp_file
    config = Tildeverse::Config.new(temp_file)
    config.update_frequency = 'always'
    allow(config).to receive(:updated_on).and_return(Date.today + 1)
    expect(config.update_required?).to eq true
    allow(config).to receive(:updated_on).and_return(Date.today)
    expect(config.update_required?).to eq true
    allow(config).to receive(:updated_on).and_return(Date.today - 1)
    expect(config.update_required?).to eq true
  end

  it "#update_required? <- update_frequency = 'day'" do
    kill_temp_file
    config = Tildeverse::Config.new(temp_file)
    config.update_frequency = 'day'
    allow(config).to receive(:updated_on).and_return(Date.today + 1)
    expect(config.update_required?).to eq false
    allow(config).to receive(:updated_on).and_return(Date.today)
    expect(config.update_required?).to eq false
    allow(config).to receive(:updated_on).and_return(Date.today - 1)
    expect(config.update_required?).to eq true
  end

  it "#update_required? <- update_frequency = 'week'" do
    kill_temp_file
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

  it "#update_required? <- update_frequency = 'month'" do
    kill_temp_file
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
end
