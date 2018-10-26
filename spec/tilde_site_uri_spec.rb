#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::TildeSiteURI' do
  let(:example_data) do
    {
      'https://tilde.town/~dan/users.json' => {
        name:             'tilde.town',
        root:             'https://tilde.town',
        list:             'https://tilde.town/~dan/users.json',
        homepage_format:  'https://tilde.town/~USER/'
      },
      'http://example.com' => {
        name:             'example.com',
        root:             'http://example.com',
        list:             'http://example.com',
        homepage_format:  'http://example.com/~USER/'
      }
    }
  end

  describe '#new' do
    it 'should fail if URI is not HTTP or HTTPS' do
      [
        'httpss://tilde.town/~dan/users.json',
        'ftp://tilde.town/~dan/users.json',
        URI('ftp://tilde.town/~dan/users.json'),
        URI('mailto:foo@example.com'),
        'foo',
        123
      ].each do |uri|
        expect do
          Tildeverse::TildeSiteURI.new(uri)
        end.to raise_error(Tildeverse::Error::InvalidURIError)
      end
    end

    it 'should correctly create an instance' do
      [
        'http://tilde.town/~dan/users.json',
        'https://tilde.town/~dan/users.json',
        URI('http://tilde.town/~dan/users.json'),
        URI('https://tilde.town/~dan/users.json')
      ].each do |uri|
        expect do
          Tildeverse::TildeSiteURI.new(uri)
        end.not_to raise_error
      end
    end

    it 'should return the expected default values' do
      example_data.each do |uri, expectations|
        obj = Tildeverse::TildeSiteURI.new(uri)
        expectations.each do |message, result|
          expect(obj.send(message)).to eq result
        end
      end
    end
  end

  describe '#uri' do
    it 'should be a URI::HTTP' do
      [
        'http://tilde.town/~dan/users.json',
        'https://tilde.town/~dan/users.json'
      ].each do |uri|
        obj = Tildeverse::TildeSiteURI.new(uri)
        expect(obj.uri).to be_a URI::HTTP
      end
    end

    it 'should be the delegate object on #method_missing' do
      obj = Tildeverse::TildeSiteURI.new('http://example.com')
      expect { obj.host            }.not_to raise_error
      expect { obj.scheme          }.not_to raise_error
      expect { obj.foo             }.to raise_error NoMethodError
      expect { obj.bar             }.to raise_error NoMethodError

      # Messing with #method_missing should not break defined methods
      expect { obj.name            }.not_to raise_error
      expect { obj.homepage_format }.not_to raise_error
      expect { obj.uri.host        }.not_to raise_error
      expect { obj.uri.scheme      }.not_to raise_error
    end

    it 'should be the delegate object on #respond_to_missing?' do
      obj = Tildeverse::TildeSiteURI.new('http://example.com')
      expect(obj.respond_to?(:host)           ).to be true
      expect(obj.respond_to?(:scheme)         ).to be true
      expect(obj.respond_to?(:foo)            ).to be false
      expect(obj.respond_to?(:bar)            ).to be false

      # Messing with #respond_to_missing? should not break defined methods
      expect(obj.respond_to?(:name)           ).to be true
      expect(obj.respond_to?(:homepage_format)).to be true
      expect(obj.uri.respond_to?(:host)       ).to be true
      expect(obj.uri.respond_to?(:scheme)     ).to be true
    end
  end

  describe '#name' do
    it 'should be able to overwrite and restore default values' do
      uri, expectations = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      expect(obj.name).to eq expectations[:name]
      obj.name = 'foobar'
      expect(obj.name).to eq 'foobar'
      obj.name = nil
      expect(obj.name).to eq expectations[:name]
    end
  end

  describe '#root' do
    it 'should be able to overwrite and restore default values' do
      uri, expectations = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      expect(obj.root).to eq expectations[:root]
      obj.root = 'foobar'
      expect(obj.root).to eq 'foobar'
      obj.root = nil
      expect(obj.root).to eq expectations[:root]
    end
  end

  describe '#list' do
    it 'should be able to overwrite and restore default values' do
      uri, expectations = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      expect(obj.list).to eq expectations[:list]
      obj.list = 'foobar'
      expect(obj.list).to eq 'foobar'
      obj.list = nil
      expect(obj.list).to eq expectations[:list]
    end
  end

  describe '#homepage_format' do
    it 'should be able to overwrite and restore default values' do
      uri, expectations = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      expect(obj.homepage_format).to eq expectations[:homepage_format]
      obj.homepage_format = 'foobar'
      expect(obj.homepage_format).to eq 'foobar'
      obj.homepage_format = nil
      expect(obj.homepage_format).to eq expectations[:homepage_format]
    end
  end

  describe '#homepage(user)' do
    it 'should return the expected URI' do
      uri, = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      result = obj.homepage('foobar')
      expect(result).to be_a String
      expect(result.to_s).to eq 'https://tilde.town/~foobar/'
    end

    it 'should error if template is in an incorrect format' do
      uri, = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      obj.homepage_format = 'https://tilde.town/~FOOBAR/'
      expect do
        obj.homepage('foobar')
      end.to raise_error ArgumentError
    end
  end

  describe '#email(user)' do
    it 'should return the expected email address' do
      uri, = example_data.first
      obj = Tildeverse::TildeSiteURI.new(uri)
      result = obj.email('foobar')
      expect(result).to be_a String
      expect(result).to eq 'foobar@tilde.town'
    end
  end
end
