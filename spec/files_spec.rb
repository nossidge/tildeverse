#!/usr/bin/env ruby

describe 'Tildeverse::Files' do

  def rootpath
    Pathname(__FILE__).dirname.parent
  end

  def specpath
    rootpath + 'spec'
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

  describe '#dir_input' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.dir_input
      check = rootpath + 'input'
      expect(filepath).to eq check
    end
  end

  describe '#dir_output' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.dir_output
      check = rootpath + 'output'
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
      check = rootpath + 'output' + 'index.html'
      expect(filepath).to eq check
    end
  end

  describe '#output_json_users' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.output_json_users
      check = rootpath + 'output' + 'users.json'
      expect(filepath).to eq check
    end
  end

  describe '#output_json_tildeverse' do
    it 'should point to the correct path' do
      filepath = Tildeverse::Files.output_json_tildeverse
      check = rootpath + 'output' + 'tildeverse.json'
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
      expect(data1).to eq data2
    end
  end

  describe '#files_to_copy' do
    it 'should contain an array of valid filepaths' do
      files = Tildeverse::Files.files_to_copy
      expect(files).to be_a Array
      files.each do |f|
        file = Tildeverse::Files.dir_input + f
        expect(file.exist?).to be true
      end
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

  describe '#write?' do
    it 'should return true if user has correct permissions' do
      files = Tildeverse::Files.files_to_copy
      files.map! { |f| Tildeverse::Files.dir_input + f }
      can_write = Tildeverse::Files.write?(files)
      expect(can_write).to be true
    end

    it 'should return false if user does not have permission' do
      files = Tildeverse::Files.files_to_copy
      files.map! { |f| Pathname('foo/not_valid') + f }
      msg  = "You do not have permission to write to the output location.\n"
      msg += "Please contact your admin to get write access to:\n"
      msg += files.map(&:to_s).join("\n")
      expect(STDOUT).to receive(:puts).with(msg)
      can_write = Tildeverse::Files.write?(files)
      expect(can_write).to be false
    end
  end

  describe '#save_json' do
    def filepath
      specpath + 'tmp.json'
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
      specpath + 'tmp.txt'
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
      specpath + 'tmp_list.txt'
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
