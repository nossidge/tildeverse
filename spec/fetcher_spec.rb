#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Fetcher' do

  # Implement the bare minimum to quack like a Data object
  let(:data) do
    double('Data', :save_with_config => nil, :clear => nil)
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
    it 'should return true if valid URL' do
      fetcher = Tildeverse::Fetcher.new(data, remote_resource_no_error)

      results = nil
      expect(STDOUT).to_not receive(:puts)
      expect { results = fetcher.fetch }.to_not raise_error
      expect(results).to eq true
    end

    it 'should return false if invalid URL' do
      fetcher = Tildeverse::Fetcher.new(data, remote_resource_error)
      msg = remote_resource_error.msg

      results = nil
      expect(STDOUT).to receive(:puts).with(msg)
      expect { results = fetcher.fetch }.to_not raise_error
      expect(results).to eq false
    end
  end

  describe '#write_permissions?' do
    let(:results) do
      fetcher = Tildeverse::Fetcher.new(data, remote_resource_no_error)
      fetcher.send(:write_permissions?)
    end

    it 'should return false if invalid write permissions' do
      allow(Tildeverse::Files).to receive(:write?).and_return(false)
      expect(results).to eq false
    end

    it 'should return false if invalid write permissions' do
      dbl = double('input_txt_tildeverse', :exist? => true, :writable? => false)
      allow(Tildeverse::Files).to receive(:input_txt_tildeverse).and_return(dbl)
      expect(STDOUT).to receive(:puts)
      expect(results).to eq false
    end

    it 'should return true if valid write permissions' do
      [
        { exist?: false, writable?: true },
        { exist?: false, writable?: false },
        { exist?: true,  writable?: true },
      ].each do |args|
        dbl = double('input_txt_tildeverse', args)
        allow(Tildeverse::Files).to receive(:input_txt_tildeverse).and_return(dbl)
        expect(results).to eq true
      end
    end
  end
end
