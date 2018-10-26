#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Error' do

  # Base class to inherit for all Tildeverse exception classes
  describe 'Error' do
    let(:error) { Tildeverse::Error::Error.new('foo') }
    it 'should be a StandardError' do
      expect(error).to be_a StandardError
    end
    it 'should declare a default #message' do
      expect(error.message).to eq 'foo'
    end
    it 'should declare a default #console_message' do
      expect(error.console_message).to eq 'ERROR: foo'
    end
  end

  ##############################################################################

  # Base class to inherit for PermissionDenied exception classes
  describe 'PermissionDeniedError' do
    let(:error) { Tildeverse::Error::PermissionDeniedError.new }
    let(:msg) { %(Current user is not authorised to perform this task) }
    it 'should be a Tildeverse::Error::Error' do
      expect(error).to be_a Tildeverse::Error::Error
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end

  describe 'DeniedByConfig' do
    let(:error) { Tildeverse::Error::DeniedByConfig.new }
    let(:msg) { %(ERROR: The current user is not authorised) }
    it 'should be a Tildeverse::Error::PermissionDeniedError' do
      expect(error).to be_a Tildeverse::Error::PermissionDeniedError
    end
    it 'should declare a meaningful #console_message' do
      expect(error.console_message).to start_with msg
    end
  end

  describe 'DeniedByOS' do
    let(:error) { Tildeverse::Error::DeniedByOS.new }
    let(:msg) { %(ERROR: The current user is not authorised) }
    it 'should be a Tildeverse::Error::PermissionDeniedError' do
      expect(error).to be_a Tildeverse::Error::PermissionDeniedError
    end
    it 'should declare a meaningful #console_message' do
      expect(error.console_message).to start_with msg
    end
  end

  ##############################################################################

  # Developer error that should never be seen by console users
  describe 'InvalidURIError' do
    let(:error) { Tildeverse::Error::InvalidURIError.new('foo') }
    let(:msg) { %(Tilde URI must be HTTP or HTTPS: "foo") }
    it 'should be a Tildeverse::Error::Error' do
      expect(error).to be_a Tildeverse::Error::Error
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
    it "should declare a 'developer_error' #console_message" do
      expect(error).to receive(:developer_error).and_call_original
      error.console_message
    end
  end
end
