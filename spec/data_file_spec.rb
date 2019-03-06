#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::DataFile' do

  before(:all) do
    @dir_datafile = Tildeverse::Files.dir_root + 'datafile'
    FileUtils.makedirs(@dir_datafile) unless @dir_datafile.exist?
  end

  after(:all) do
    FileUtils.rm_rf(@dir_datafile)
  end

  ##############################################################################

  describe '#new' do
    it 'should default to the /data/ directory' do
      dir_data = Tildeverse::Files.dir_root + 'data'
      data_file = Tildeverse::DataFile.new
      expect(data_file.dir).to eq dir_data
    end

    it 'should accept a Pathname variable' do
      data_file = Tildeverse::DataFile.new(@dir_datafile)
      expect(data_file.dir).to eq @dir_datafile
    end

    it 'should convert a string to a Pathname variable' do
      data_file = Tildeverse::DataFile.new(@dir_datafile.to_s)
      expect(data_file.dir).to eq @dir_datafile
    end
  end

  ##############################################################################

  describe '#main' do
    let(:data_file) { Tildeverse::DataFile.new(@dir_datafile) }

    it 'should return a Pathname' do
      expect(data_file.main).to be_a Pathname
    end

    it "should return 'tildeverse.txt'" do
      file = data_file.dir + 'tildeverse.txt'
      expect(data_file.main).to eq file
    end
  end

  ##############################################################################

  describe '#todays_file' do
    let(:data_file) { Tildeverse::DataFile.new(@dir_datafile) }

    it 'should return a Pathname' do
      expect(data_file.send(:todays_file)).to be_a Pathname
    end

    it 'should use the correct timestamp format' do
      date = Time.now.strftime('%Y%m%d')
      expected = data_file.dir + "tildeverse_#{date}.txt"
      expect(data_file.send(:todays_file)).to eq expected
    end
  end

  ##############################################################################

  describe '#get!' do
    let(:data_file) { Tildeverse::DataFile.new(@dir_datafile) }
    let(:main_file) { @dir_datafile + 'tildeverse.txt' }
    let(:todays_file) { data_file.send(:todays_file) }

    let(:random_string) do
      lambda do
        letters = ('a'..'z').to_a + ('A'..'Z').to_a
        Array.new(16) { letters.sample }.join
      end
    end

    let(:create_files) do
      lambda do |lines_and_filename|
        lines_and_filename.each do |lines, filename|
          filepath = @dir_datafile + filename
          File.open(filepath, 'w') do |f|
            lines.times { f.puts random_string.call }
          end
        end
      end
    end

    let(:delete_all_files) do
      lambda do
        @dir_datafile.glob('tildeverse*.txt').each do |filepath|
          FileUtils.rm(filepath)
        end
      end
    end

    run_scenario = lambda do |index, scenario|
      context "scenario #{index}" do
        let(:best)    { @dir_datafile + scenario[:best] }
        before(:each) { create_files.call(scenario[:files]) }
        after(:each)  { delete_all_files.call }

        it 'should identify the best file' do
          expect(data_file.get!).to eq best
        end

        it 'should copy the best file to main and todays file' do
          first_line = best.readline

          data_file.get!

          expect(main_file.readline).to eq first_line
          expect(todays_file.readline).to eq first_line
        end

        it 'should remove unwanted backups' do
          starting_files = @dir_datafile.children
          expect(starting_files.count).to eq scenario[:files].count

          data_file.get!

          remaining_files = @dir_datafile.children
          expect(remaining_files.count).to eq 2
          expect(remaining_files).to include main_file
          expect(remaining_files).to include todays_file
        end
      end
    end

    [
      {
        best: 'tildeverse.txt',
        files: [
          [10, 'tildeverse.txt'],
          [ 9, 'tildeverse_20181122.txt']
        ]
      }, {
        best: 'tildeverse_20181122.txt',
        files: [
          [10, 'tildeverse.txt'],
          [19, 'tildeverse_20181122.txt']
        ]
      }, {
        best: 'tildeverse_20181124.txt',
        files: [
          [ 0, 'tildeverse.txt'],
          [ 0, 'tildeverse_20181120.txt'],
          [ 0, 'tildeverse_20181121.txt'],
          [17, 'tildeverse_20181122.txt'],
          [17, 'tildeverse_20181123.txt'],
          [17, 'tildeverse_20181124.txt'],
          [ 0, 'tildeverse_20181125.txt'],
          [ 0, 'tildeverse_20181126.txt'],
        ]
      }, {
        best: 'tildeverse_20181123.txt',
        files: [
          [ 0, 'tildeverse.txt'],
          [ 0, 'tildeverse_20181120.txt'],
          [ 0, 'tildeverse_20181121.txt'],
          [17, 'tildeverse_20181122.txt'],
          [17, 'tildeverse_20181123.txt'],
          [10, 'tildeverse_20181124.txt'],
          [10, 'tildeverse_20181125.txt'],
          [ 0, 'tildeverse_20181126.txt'],
        ]
      }, {
        best: 'tildeverse.txt',
        files: [
          [17, 'tildeverse.txt'],
          [ 0, 'tildeverse_20181120.txt'],
          [ 0, 'tildeverse_20181121.txt'],
          [17, 'tildeverse_20181122.txt'],
          [17, 'tildeverse_20181123.txt'],
          [10, 'tildeverse_20181124.txt'],
          [10, 'tildeverse_20181125.txt'],
          [ 0, 'tildeverse_20181126.txt'],
        ]
      }
    ].each.with_index do |scenario, index|
      run_scenario.call(index, scenario)
    end
  end
end
