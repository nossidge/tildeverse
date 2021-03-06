#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Files' do
  include_context 'before_each__seed_the_data'

  def rootpath
    Tildeverse::Files.dir_root
  end

  def example_data
    [
      {
        'name' => 'Paul',
        'instruments' => [
          'bass guitar',
          'keyboards'
        ]
      }, {
        'name' => 'John',
        'instruments' => [
          'rhythm guitar',
          'keyboards'
        ]
      }, {
        'name' => 'George',
        'instruments' => [
          'lead guitar',
          'sitar'
        ]
      }, {
        'name' => 'Ringo',
        'instruments' => [
          'drums',
          'percussion'
        ]
      }
    ]
  end

  ##############################################################################

  describe '#dir_root' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.dir_root
      check = rootpath
      expect(filepath).to eq check
    end
  end

  describe '#dir_data' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.dir_data
      check = rootpath + 'data'
      expect(filepath).to eq check
    end
  end

  describe '#dir_web' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.dir_web
      check = rootpath + 'web'
      expect(filepath).to eq check
    end
  end

  describe '#dir_public' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.dir_public
      check = rootpath + 'web' + 'public'
      expect(filepath).to eq check
    end
  end

  describe '#config_yml' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.config_yml
      check = rootpath + 'config' + 'config.yml'
      expect(filepath).to eq check
    end
  end

  describe '#input_tildeverse_txt_as_hash' do
    it 'should return a hash' do
      data = Tildeverse::Files.input_tildeverse_txt_as_hash
      expect(data).to be_a Hash
      expect(data).to_not be_empty
    end
  end

  describe '#output_html_index' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.output_html_index
      check = rootpath + 'web' + 'public' + 'index.html'
      expect(filepath).to eq check
    end
  end

  describe '#output_json_users' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.output_json_users
      check = rootpath + 'web' + 'public' + 'users.json'
      expect(filepath).to eq check
    end
  end

  describe '#output_json_tildeverse' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.output_json_tildeverse
      check = rootpath + 'web' + 'public' + 'tildeverse.json'
      expect(filepath).to eq check
    end
  end

  describe '#output_tildeverse!' do
    it 'should return the data from the file' do
      data = Tildeverse::Files.output_tildeverse!
      expect(data).to be_a Hash
      expect(data).to_not be_empty
    end

    it 'should return an empty hash if given an invalid filepath' do
      singleton = Tildeverse::Files.dup
      def singleton.output_json_tildeverse
        'foo/not_valid/sausage.json'
      end
      data = singleton.output_tildeverse!
      expect(data).to be_a Hash
      expect(data).to be_empty
    end
  end

  describe '#output_tildeverse' do
    it 'should return the same object as #output_tildeverse!' do
      data1 = Tildeverse::Files.output_tildeverse
      data2 = Tildeverse::Files.output_tildeverse!

      # There may be some differences between generation times,
      # but it should never be more than one second
      time1 = data1['metadata']['date_unix']
      time2 = data2['metadata']['date_unix']
      expect(time1 == time2 || time1 == time2 - 1).to be true

      # Remove 'date_unix' from the equation, and compare the hash
      data1['metadata']['date_unix'] = 0
      data2['metadata']['date_unix'] = 0
      expect(data1).to eq data2
    end
  end

  describe '#remote_json' do
    it 'should resolve to the correct URL' do
      url = 'https://tilde.town/~nossidge/tildeverse/tildeverse.json'
      expect(Tildeverse::Files.remote_json).to eq url
    end
  end

  describe '#remote_txt' do
    it 'should resolve to the correct URL' do
      url = 'https://tilde.town/~nossidge/tildeverse/tildeverse.txt'
      expect(Tildeverse::Files.remote_txt).to eq url
    end
  end

  describe '#save_json' do
    def filepath
      rootpath + 'tmp.json'
    end

    after(:all) do
      FileUtils.rm(filepath) if filepath.exist?
    end

    it 'should create a new file and save to it' do
      expect(filepath.exist?).to be false
      Tildeverse::Files.save_json(example_data, filepath)
      expect(filepath.exist?).to be true
    end

    it 'should correctly load data from the saved file' do
      data = File.open(filepath, 'r') { |f| f.readlines.map(&:chomp) }
      expect(JSON[data.join]).to eq example_data
      FileUtils.rm(filepath)
      expect(filepath.exist?).to be false
    end
  end

  describe '#save_text' do
    def filepath
      rootpath + 'tmp.txt'
    end

    after(:all) do
      FileUtils.rm(filepath) if filepath.exist?
    end

    it 'should create a new file and save to it' do
      expect(filepath.exist?).to be false
      Tildeverse::Files.save_text(example_data, filepath)
      expect(filepath.exist?).to be true
    end

    it 'should correctly load data from the saved file' do
      data = File.open(filepath, 'r') { |f| f.readlines.map(&:chomp) }
      expect(JSON[data.join.gsub('=>', ': ')]).to eq example_data
      FileUtils.rm(filepath)
      expect(filepath.exist?).to be false
    end
  end

  describe '#save_array' do
    def filepath
      rootpath + 'tmp_list.txt'
    end

    let(:array) do
      ['paul', 'john', :george, 'RINGO', 1961]
    end

    after(:all) do
      FileUtils.rm(filepath) if filepath.exist?
    end

    it 'should create a new file and save to it' do
      expect(filepath.exist?).to be false
      Tildeverse::Files.save_array(array, filepath)
      expect(filepath.exist?).to be true
    end

    it 'should correctly load data from the saved file' do
      data = File.open(filepath, 'r') { |f| f.readlines.map(&:chomp) }
      expect(data).to eq array.map(&:to_s)
      FileUtils.rm(filepath)
      expect(filepath.exist?).to be false
    end
  end
end
