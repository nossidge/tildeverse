#!/usr/bin/env ruby

require_relative '../lib/tildeverse/site_serializer_class'

describe 'Tildeverse::SiteSerializerClass' do
  def site
    Tildeverse.site('tilde.town')
  end
  def site_serializer_class
    Tildeverse::SiteSerializerClass.new(site)
  end

  describe '#serialize_output' do
    it 'should duplicate the output of site#serialize_output' do
      results = site_serializer_class.serialize_output
      expect(results).to eq site.serialize_output
    end
  end
end
