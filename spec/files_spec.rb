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

  it '#dir_root' do
    filepath = Tildeverse::Files.dir_root
    check = rootpath
    expect(filepath).to eq check
  end

  it '#dir_input' do
    filepath = Tildeverse::Files.dir_input
    check = rootpath + 'input'
    expect(filepath).to eq check
  end

  it '#dir_output' do
    filepath = Tildeverse::Files.dir_output
    check = rootpath + 'output'
    expect(filepath).to eq check
  end

  it '#output_html_index' do
    filepath = Tildeverse::Files.output_html_index
    check = rootpath + 'output' + 'index.html'
    expect(filepath).to eq check
  end

  it '#output_json_users' do
    filepath = Tildeverse::Files.output_json_users
    check = rootpath + 'output' + 'users.json'
    expect(filepath).to eq check
  end

  it '#output_json_tildeverse' do
    filepath = Tildeverse::Files.output_json_tildeverse
    check = rootpath + 'output' + 'tildeverse.json'
    expect(filepath).to eq check
  end

  it '#output_tildeverse!' do
    data = Tildeverse::Files.output_tildeverse!
    expect(data).to be_a Hash
    expect(data).to_not be_empty

    singleton = Tildeverse::Files.dup
    def singleton.output_json_tildeverse
      'foo/not_valid/sausage.json'
    end
    data = singleton.output_tildeverse!
    expect(data).to be_a Hash
    expect(data).to be_empty
  end

  it '#files_to_copy' do
    files = Tildeverse::Files.files_to_copy
    expect(files).to be_a Array
    files.each do |f|
      file = Tildeverse::Files.dir_input + f
      expect(file.exist?).to be true
    end
  end

  it '#remote_json' do
    url = 'https://tilde.town/~nossidge/tildeverse/tildeverse.json'
    expect(Tildeverse::Files.remote_json).to eq url
  end

  it '#write?' do
    files = Tildeverse::Files.files_to_copy
    files.map! { |f| Tildeverse::Files.dir_input + f }
    can_write = Tildeverse::Files.write?(files)
    expect(can_write).to be true

    files = Tildeverse::Files.files_to_copy
    files.map! { |f| Pathname('foo/not_valid') + f }
    msg  = "You do not have permission to write to the output location.\n"
    msg += "Please contact your admin to get write access to:\n"
    msg += files.map(&:to_s).join("\n")
    expect(STDOUT).to receive(:puts).with(msg)
    can_write = Tildeverse::Files.write?(files)
    expect(can_write).to be false
  end

  it '#save_json' do
    filepath = specpath + 'tmp.json'
    expect(filepath.exist?).to be false
    Tildeverse::Files.save_json(example_data, filepath)
    expect(filepath.exist?).to be true
    data = File.open(filepath, 'r') { |f| f.readlines.map(&:chomp) }
    expect(JSON[data.join]).to eq example_data
    FileUtils.rm(filepath)
    expect(filepath.exist?).to be false
  end

  it '#save_text' do
    filepath = specpath + 'tmp.txt'
    expect(filepath.exist?).to be false
    Tildeverse::Files.save_text(example_data, filepath)
    expect(filepath.exist?).to be true
    data = File.open(filepath, 'r') { |f| f.readlines.map(&:chomp) }
    expect(JSON[data.join.gsub('=>', ': ')]).to eq example_data
    FileUtils.rm(filepath)
    expect(filepath.exist?).to be false
  end

  it '#save_array' do
    filepath = specpath + 'tmp_list.txt'
    expect(filepath.exist?).to be false
    array = ['paul', 'john', :george, 'RINGO', 1961]
    Tildeverse::Files.save_array(array, filepath)
    expect(filepath.exist?).to be true
    data = File.open(filepath, 'r') { |f| f.readlines.map(&:chomp) }
    expect(data).to eq array.map(&:to_s)
    FileUtils.rm(filepath)
    expect(filepath.exist?).to be false
  end

  it '#makedirs' do
    pathname = specpath + 'tmp'
    expect(pathname.exist?).to be false
    Tildeverse::Files.makedirs(pathname)
    expect(pathname.exist?).to be true
    FileUtils.rmtree(pathname)
    expect(pathname.exist?).to be false

    pathname = specpath + 'tmp' + 'tmp_deeper'
    expect(pathname.exist?).to be false
    Tildeverse::Files.makedirs(pathname)
    expect(pathname.exist?).to be true
    FileUtils.rmtree(pathname.parent)
    expect(pathname.exist?).to be false
  end
end
