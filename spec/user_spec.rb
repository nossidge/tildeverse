#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::User' do
  let(:site_struct) do
    Struct.new(:name) do
      def uri
        @uri ||= Tildeverse::TildeSiteURI.new('http://example.com')
      end
      def ==(other)
        name == other.name
      end
    end
  end

  let(:example_data) do
    {
      site:           site_struct.new('example.com'),
      name:           'paul',
      date_online:    Date.new(2016, 1, 2),
      date_offline:   Date.new(2018, 6, 10),
      date_modified:  Date.new(2017, 2, 9),
      date_tagged:    Date.new(2017, 3, 25),
      tags:           %w[bar baz foo]
    }
  end

  let(:user) do
    Tildeverse::User.new(example_data)
  end

  ##############################################################################

  describe '#new' do
    it 'should correctly apply the input parameters hash' do
      example_data.each do |k, v|
        expect(user.send(k)).to eq v
      end
      expect(user.site.name).to eq 'example.com'
    end

    it 'should correctly apply the defaults to unspecified parameters' do
      user = Tildeverse::User.new(site: 'site.foo', name: 'site_foo')
      expect(user.date_online).to   eq Tildeverse::TildeDate.new(nil)
      expect(user.date_offline).to  eq Tildeverse::TildeDate.new(nil)
      expect(user.date_modified).to eq Tildeverse::TildeDate.new(nil)
      expect(user.date_tagged).to   eq Tildeverse::TildeDate.new(nil)
      expect(user.tags).to          eq Tildeverse::TagArray.new(nil)
      expect(user.site).to          eq 'site.foo'
      expect(user.name).to          eq 'site_foo'
    end

    it 'should fail without necessary parameters' do
      expect do
        Tildeverse::User.new
      end.to raise_error(ArgumentError)

      expect do
        Tildeverse::User.new(site: 'site.foo')
      end.to raise_error(ArgumentError)

      expect do
        Tildeverse::User.new(name: 'site_foo')
      end.to raise_error(ArgumentError)
    end
  end

  ##############################################################################

  describe '#serialize' do
    it 'should be an instance of UserSerializer' do
      serializer = user.serialize
      expect(serializer).to be_a Tildeverse::UserSerializer
    end
  end

  describe '#to_s' do
    it 'should return a string' do
      expect(user.to_s).to be_a String
    end
    it 'should delegate the method to the #serialize UserSerializer' do
      expect(user.to_s).to eq user.serialize.to_s
    end
  end

  ##############################################################################

  describe_date_writer_method = proc do |attribute|
    describe "##{attribute}=" do
      it 'should accept String(YYYY-MM-DD), Date, or TildeDate' do
        [
          '1970-01-01',
          '1984-01-01',
          '2018-11-01',
          '2022-07-19'
        ].each do |date_string|
          expectation = Tildeverse::TildeDate.new(date_string)
          [
            date_string,
            Date.parse(date_string),
            Tildeverse::TildeDate.new(date_string)
          ].each do |date|
            user.send("#{attribute}=", date)
            expect(user.send(attribute)).to eq expectation
          end
        end
      end

      it "should accept String containing '-', and Nil" do
        expectation = Tildeverse::TildeDate.new(nil)
        ['-', nil].each do |i|
          user.send("#{attribute}=", i)
          expect(user.send(attribute)).to eq expectation
        end
      end

      it 'should reject otherwise' do
        ['foo', String, (0..4), true, false, {}].each do |junk|
          expect do
            user.send("#{attribute}=", junk)
          end.to raise_error(ArgumentError)
        end
      end
    end
  end
  describe_date_writer_method.call(:date_offline)
  describe_date_writer_method.call(:date_modified)

  describe '#tags=' do
    it 'should reset the tags array to a new value' do
      new_tags = %w[blog code]
      user.tags = new_tags
      expect(user.tags).to eq new_tags
      expect(user.date_tagged).to eq Date.today
    end

    it 'should fail by default when any tag is invalid' do
      old_date_tagged = user.date_tagged
      new_tags = %w[blog code foo]
      expect do
        user.tags = new_tags
      end.to raise_error(Tildeverse::Error::InvalidTags)
      expect(user.date_tagged).to eq old_date_tagged
    end
  end

  describe '#online?' do
    it 'should return a boolean value' do
      expect(user.online?).to eq false
    end

    let(:test_with_dates) do
      proc do |expectation, str_online, str_offline|
        date_online  = Tildeverse::TildeDate.new(str_online)
        date_offline = Tildeverse::TildeDate.new(str_offline)
        allow(user).to receive(:date_online).and_return(date_online)
        allow(user).to receive(:date_offline).and_return(date_offline)
        expect(user.online?).to eq expectation
      end
    end

    it 'should work as expected' do
      test_with_dates.call(true,  '2018-11-01', '-')
      test_with_dates.call(false, '2018-11-01', '2018-11-01')
      test_with_dates.call(false, '2018-11-01', '2070-01-02')
      test_with_dates.call(false, '-',          '-')
      test_with_dates.call(false, '-',          '2018-11-01')
    end
  end

  describe '#homepage' do
    it 'should delegate the method to a TildeSiteURI object' do
      expect(user.site.uri).to receive(:homepage).with(user.name)
      user.homepage
    end
  end

  describe '#homepage_encoded' do
    it 'should delegate the method to a TildeSiteURI object' do
      encoded_name = URI.encode_www_form_component(user.name)
      expect(user.site.uri).to receive(:homepage).with(encoded_name)
      user.homepage
    end
  end

  describe '#email' do
    it 'should delegate the method to a TildeSiteURI object' do
      expect(user.site.uri).to receive(:email).with(user.name)
      user.email
    end
  end

  describe '#date_modified!' do
    let(:date_string) { 'Wed, 21 Oct 2015 07:28:00 GMT' }
    let(:date_time)   { DateTime.new(2015, 10, 21, 7, 28, 0, 'GMT') }
    let(:date_tilde)  { Tildeverse::TildeDate.new('2015-10-21') }

    it 'should correctly query the homepage and return the date' do
      header = { 'last-modified' => date_string }
      allow(Net::HTTP).to receive(:get_response).and_return(header)
      user = Tildeverse.site('tilde.town').user('nossidge')
      expect(user.date_modified).to eq Tildeverse::TildeDate.new('2017-04-02')
      expect(user.date_modified!).to eq date_time
      expect(user.date_modified).to eq date_tilde
    end

    it "should return Nil if header does not send 'last-modified'" do
      header = { 'foo' => 'bar' }
      allow(Net::HTTP).to receive(:get_response).and_return(header)
      user = Tildeverse.site('tilde.town').user('nossidge')
      expect(user.date_modified!).to be nil
    end
  end

  describe '#update_date_tagged!' do
    {
      String:    '2019-03-09',
      Date:      Date.new(2019, 3, 9),
      TildeDate: Tildeverse::TildeDate.new('2019-03-09')
    }.each do |type, value|
      it "should accept a #{type}" do
        expect(user.date_tagged.to_s).to eq '2017-03-25'
        user.update_date_tagged!(value)
        expect(user.date_tagged.to_s).to eq value.to_s
      end
    end
  end
end
