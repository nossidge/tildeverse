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
      allow_any_instance_of(Tildeverse::TagMerger).to receive(:merge)
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

    it 'should raise error if user not authorised by config' do
      allow(data.config).to receive(:authorised?).and_return(false)
      expect { result }.to raise_error(Tildeverse::Error::DeniedByConfig)
    end
  end
end
