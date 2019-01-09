#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::Error' do
  let(:dev_error_msg) { 'Developer error! You should not be seeing this!' }
  let(:issue_link_msg) { 'https://github.com/nossidge/tildeverse/issues' }

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

  describe 'AbstractMethodError' do
    let(:klass)          { Tildeverse::Error::AbstractMethodError }
    let(:method_name)    { 'to_s' }
    let(:msg)            { 'foo bar baz' }
    let(:error_with_msg) { klass.new(method_name, msg) }
    let(:error)          { klass.new(method_name) }
    it 'should be a Tildeverse::Error' do
      expect(error_with_msg).to be_a Tildeverse::Error
      expect(error).to          be_a Tildeverse::Error
    end
    it 'should return initialize param as #message' do
      expect(error_with_msg.message).to eq msg
    end
    it 'should include method name in default #message' do
      expect(error.message).to include(method_name)
    end
    it "should declare a 'developer_error' #console_message" do
      expect(error).to receive(:developer_error).and_call_original
      console_message = error.console_message
      expect(console_message).to include(dev_error_msg)
      expect(console_message).to include(issue_link_msg)
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

  # Base class to inherit for URIError exception classes
  describe 'URIError' do
    let(:uri) { 'http://example.com' }
    let(:msg) { 'foo bar baz' }
    let(:error) { Tildeverse::Error::URIError.new(uri, msg) }
    it 'should be a Tildeverse::Error' do
      expect(error).to be_a Tildeverse::Error
    end
    it 'should return initialize param as #message' do
      expect(error.message).to eq msg
    end
  end

  # Developer error that should never be seen by console users
  describe 'InvalidURIError' do
    let(:error) { Tildeverse::Error::InvalidURIError.new('foo') }
    let(:msg) { %(Tilde URI must be HTTP or HTTPS: "foo") }
    it 'should be a Tildeverse::Error::URIError' do
      expect(error).to be_a Tildeverse::Error::URIError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
    it "should declare a 'developer_error' #console_message" do
      expect(error).to receive(:developer_error).and_call_original
      console_message = error.console_message
      expect(console_message).to include(dev_error_msg)
      expect(console_message).to include(issue_link_msg)
    end
  end

  describe 'OfflineURIError' do
    let(:error) { Tildeverse::Error::OfflineURIError.new('foo') }
    let(:msg) { %(URI is offline: "foo") }
    it 'should be a Tildeverse::Error::URIError' do
      expect(error).to be_a Tildeverse::Error::URIError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
    it "should declare a 'developer_issue' #console_message" do
      expect(error).to receive(:developer_issue).and_call_original
      console_message = error.console_message
      expect(console_message).to_not include(dev_error_msg)
      expect(console_message).to include(issue_link_msg)
    end
  end

  ##############################################################################

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

  describe 'UpdatedOnError' do
    let(:error) { Tildeverse::Error::UpdatedOnError.new }
    let(:msg) { %('updated_on' must be a date in the format 'yyyy-mm-dd') }
    it 'should be a Tildeverse::Error::ConfigError' do
      expect(error).to be_a Tildeverse::Error::ConfigError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
  end

  ##############################################################################

  # Base class to inherit for ScrapeError exception classes
  describe 'ScrapeError' do
    let(:site_name) { 'example.com' }
    let(:msg) { 'foo bar baz' }
    let(:error) { Tildeverse::Error::ScrapeError.new(site_name, msg) }
    it 'should be a Tildeverse::Error' do
      expect(error).to be_a Tildeverse::Error
    end
    it 'should return initialize param as #message' do
      expect(error.message).to eq msg
    end
  end

  describe 'NoUsersFoundError' do
    let(:site_name) { 'example.com' }
    let(:error) { Tildeverse::Error::NoUsersFoundError.new(site_name) }
    let(:msg) { %(No users found for site: #{site_name}) }
    it 'should be a Tildeverse::Error::ScrapeError' do
      expect(error).to be_a Tildeverse::Error::ScrapeError
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
    it "should declare a 'developer_issue' #console_message" do
      expect(error).to receive(:developer_issue).and_call_original
      console_message = error.console_message
      expect(console_message).to_not include(dev_error_msg)
      expect(console_message).to include(issue_link_msg)
    end
  end

  ##############################################################################

  describe 'InvalidTags' do
    let(:dodgy_tags) { %w[foo bar baz] }
    let(:error) { Tildeverse::Error::InvalidTags.new(dodgy_tags) }
    let(:msg) { %(Invalid tag encountered: #{dodgy_tags.inspect}) }
    it 'should be a Tildeverse::Error' do
      expect(error).to be_a Tildeverse::Error
    end
    it 'should declare a meaningful #message' do
      expect(error.message).to eq msg
    end
    it "should declare a 'developer_error' #console_message" do
      expect(error).to receive(:developer_error).and_call_original
      console_message = error.console_message
      expect(console_message).to include(dev_error_msg)
      expect(console_message).to include(issue_link_msg)
    end
  end
end
