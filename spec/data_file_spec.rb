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

    let(:let_authorised_return) do
      lambda do |bool|
        allow_any_instance_of(Tildeverse::Config).to(
          receive(:authorised?).and_return(bool)
        )
      end
    end

    # It's fine to ignore EOF here, we're just using it to compare 2 files
    def get_line(file)
      file.readline if file.exist?
    rescue EOFError
      nil
    end

    # Todo: Error if no file present

    run_scenario = lambda do |index, scenario|
      context "scenario #{index}" do
        let(:best)    { @dir_datafile + scenario[:best] }
        before(:each) { create_files.call(scenario[:files]) }
        after(:each)  { delete_all_files.call }

        it 'should call Config#authorised? to determine write access' do
          expect_any_instance_of(Tildeverse::Config).to receive(:authorised?)
          data_file.get!
        end

        it 'should identify the best file' do
          best_first_line = get_line(best)
          [false, true].each do |bool|
            let_authorised_return.call(bool)
            first_line = get_line(data_file.get!)
            expect(first_line).to eq best_first_line
          end
        end

        it 'should copy the best file to main and todays file, if authorised' do
          let_authorised_return.call(true)
          first_line = get_line(best)

          data_file.get!

          expect(get_line(main_file)).to eq first_line
          expect(get_line(todays_file)).to eq first_line
        end

        it 'should not copy any files, if not authorised' do
          let_authorised_return.call(false)
          first_line_main   = get_line(main_file)
          first_line_todays = get_line(todays_file)

          data_file.get!

          expect(get_line(main_file)).to eq first_line_main
          expect(get_line(todays_file)).to eq first_line_todays
        end

        it 'should remove unneeded backups, if authorised' do
          let_authorised_return.call(true)
          starting_files = @dir_datafile.children
          expect(starting_files.count).to eq scenario[:files].count

          data_file.get!

          remaining_files = @dir_datafile.children
          expect(remaining_files.count).to eq 2
          expect(remaining_files).to include main_file
          expect(remaining_files).to include todays_file
        end

        it 'should not remove unneeded backups, if not authorised' do
          let_authorised_return.call(false)
          expect(@dir_datafile.children.count).to eq scenario[:files].count

          data_file.get!

          expect(@dir_datafile.children.count).to eq scenario[:files].count
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
