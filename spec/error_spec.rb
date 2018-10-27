#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Error' do

  # Base class to inherit for all Tildeverse exception classes
  describe 'Error' do
    let(:error) { Tildeverse::Error.new('foo') }
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
    it 'should be a Tildeverse::Error' do
      expect(error).to be_a Tildeverse::Error
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
    it 'should be a Tildeverse::Error' do
      expect(error).to be_a Tildeverse::Error
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
    it "should declare a 'developer_error' #console_message" do
      expect(error).to receive(:developer_error).and_call_original
      error.console_message
    end
  end

  ##############################################################################

  # Developer error that should never be seen by console users
  describe 'ConfigError' do
    let(:error) { Tildeverse::Error::ConfigError.new('foo') }
    let(:msg) { 'foo' }
    let(:console_msg) do
      <<~MSG
        ERROR: foo
               Update the file 'config.yml' and correct this field
      MSG
    end
    it 'should be a Tildeverse::Error' do
      expect(error).to be_a Tildeverse::Error
    end
    it 'should apply the initialize arg as #message' do
      expect(error.message).to eq msg
    end
    it 'should declare a meaningful #console_message' do
      expect(error.console_message).to eq console_msg
    end
  end

  describe 'AuthorisedUsersError' do
    let(:error) { Tildeverse::Error::AuthorisedUsersError.new }
    let(:msg) { %('authorised_users' must be a valid list of users) }
    it 'should be a Tildeverse::Error::ConfigError' do
      expect(error).to be_a Tildeverse::Error::ConfigError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end

  describe 'UpdateTypeError' do
    let(:error) { Tildeverse::Error::UpdateTypeError.new }
    let(:msg) { %('update_type' must be one of: scrape, fetch) }
    it 'should be a Tildeverse::Error::ConfigError' do
      expect(error).to be_a Tildeverse::Error::ConfigError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end

  describe 'UpdateFrequencyError' do
    let(:error) { Tildeverse::Error::UpdateFrequencyError.new }
    let(:msg) { %('update_frequency' must be one of: always, day, week, month) }
    it 'should be a Tildeverse::Error::ConfigError' do
      expect(error).to be_a Tildeverse::Error::ConfigError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end

  describe 'GenerateHtmlError' do
    let(:error) { Tildeverse::Error::GenerateHtmlError.new }
    let(:msg) { %('generate_html' must be one of: true, false) }
    it 'should be a Tildeverse::Error::ConfigError' do
      expect(error).to be_a Tildeverse::Error::ConfigError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end

  describe 'UpdatedOnError' do
    let(:error) { Tildeverse::Error::UpdatedOnError.new }
    let(:msg) { %(todo) }
    it 'should be a Tildeverse::Error::ConfigError' do
      expect(error).to be_a Tildeverse::Error::ConfigError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end
end
