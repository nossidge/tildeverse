#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Fetcher' do

  # Implement the bare minimum to quack like a Config object
  let(:config) do
    double('Config', :authorised? => true)
  end

  # Implement the bare minimum to quack like a Data object
  let(:data) do
    double('Data', :config => config, :save_with_config => nil, :clear => nil)
  end

  # Implement the bare minimum to quack like a RemoteResource object
  let(:remote_resource_no_error) do
    double('RemoteResource',
      :get => nil,
      :error? => false,
      :msg => 'Cannot find resource',
      :result => nil
    )
  end
  let(:remote_resource_error) do
    double('RemoteResource',
      :get => nil,
      :error? => true,
      :msg => 'Cannot find resource',
      :result => nil
    )
  end

  ##############################################################################

  describe '#fetch' do
    it 'should return false and output a message if invalid URL' do
      fetcher = Tildeverse::Fetcher.new(data, remote_resource_error)
      msg = remote_resource_error.msg
      expect(STDOUT).to receive(:puts).with(msg)
      expect(fetcher.fetch).to eq false
    end

    let(:fetcher) { Tildeverse::Fetcher.new(data, remote_resource_no_error) }
    let(:result) { fetcher.fetch }

    it 'should correctly return if valid URL' do
      expect(STDOUT).to_not receive(:puts)
      expect { result }.to_not raise_error
    end

    it 'should call Data#clear' do
      expect(data).to receive(:clear)
      result
    end

    it 'should call Data#save_with_config' do
      expect(data).to receive(:save_with_config)
      result
    end

    it 'should raise error if user not authorised by OS' do
      allow(fetcher).to receive(:write_permissions?).and_return(false)
      expect { result }.to raise_error(Tildeverse::Error::DeniedByOS)
    end

    it 'should raise error if user not authorised by config' do
      allow(data.config).to receive(:authorised?).and_return(false)
      expect { result }.to raise_error(Tildeverse::Error::DeniedByConfig)
    end
  end

  ##############################################################################

  describe '#write_permissions?' do
    let(:fetcher) { Tildeverse::Fetcher.new(data, remote_resource_no_error) }
    let(:result) { fetcher.send(:write_permissions?) }

    it 'should return false if invalid write permissions' do
      allow(Tildeverse::Files).to receive(:write?).and_return(false)
      expect(result).to eq false
    end

    it 'should return false if invalid write permissions' do
      dbl = double('input_txt_tildeverse', :exist? => true, :writable? => false)
      allow(Tildeverse::Files).to receive(:input_txt_tildeverse).and_return(dbl)
      expect(STDOUT).to receive(:puts)
      expect(result).to eq false
    end

    it 'should return true if valid write permissions' do
      [
        { exist?: false, writable?: true },
        { exist?: false, writable?: false },
        { exist?: true,  writable?: true },
      ].each do |args|
        dbl = double('input_txt_tildeverse', args)
        allow(Tildeverse::Files).to receive(:input_txt_tildeverse).and_return(dbl)
        expect(result).to eq true
      end
    end
  end
end
