#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::TagArray' do
  let(:input_valid) do
    [
      [nil,             '-'],
      [[],              '-'],
      ['-',             '-'],
      [['-'],           '-'],
      [[:poetry],       'poetry'],
      [['poetry'],      'poetry'],
      [%w[empty prose], 'empty,prose'],
      [%i[empty prose], 'empty,prose']
    ]
  end

  let(:input_invalid) do
    [
      'foo',
      :foo,
      %w[empty prose foo],
      %i[empty prose foo]
    ]
  end

  describe '#new' do
    it 'should not fail when all tags are valid' do
      input_valid.each do |input, _|
        expect do
          Tildeverse::TagArray.new(input)
        end.to_not raise_error
      end
    end

    it "should be empty when input is '-'" do
      ['-', ['-']].each do |input|
        tag_array = Tildeverse::TagArray.new(input)
        expect(tag_array.to_a).to be_empty
      end
    end

    it 'should fail by default when any tag is invalid' do
      input_invalid.each do |input|
        expect do
          Tildeverse::TagArray.new(input)
        end.to raise_error(Tildeverse::Error::InvalidTags)
      end
    end

    it 'should never fail when validation is disabled' do
      all_inputs = input_valid.map(&:first) + input_invalid
      all_inputs.each do |input|
        expect do
          Tildeverse::TagArray.new(input, validation: false)
        end.to_not raise_error
      end
    end
  end

  describe '#to_s' do
    it 'should return the correct String object' do
      input_valid.each do |input, expected_to_s|
        tag_array = Tildeverse::TagArray.new(input)
        expect(tag_array.to_s).to eq expected_to_s
      end
    end
  end

  let(:input_merge) do
    [
      [
        [%i[foo], %i[bar], %i[baz]],
        %w[bar baz foo]
      ], [
        [%i[foo], %i[foo], %i[foo]],
        %w[foo]
      ], [
        [%i[foo], 'foo', :foo],
        %w[foo]
      ], [
        [%i[empty prose], %i[empty prose], %i[empty prose], %i[empty prose]],
        %w[empty prose]
      ], [
        [%i[empty prose], %i[empty prose], %i[foo]],
        %w[empty foo prose]
      ], [
        [%i[empty prose], %w[empty prose], :foo, nil, []],
        %w[empty foo prose]
      ]
    ]
  end

  describe 'self#merge' do
    it 'should correctly merge any number of TagArray objects' do
      input_merge.each do |tag_input, expected_merge|
        tag_array = tag_input.map do |tags|
          Tildeverse::TagArray.new(tags, validation: false)
        end
        expect do
          merged = Tildeverse::TagArray.merge(*tag_array)
          expect(merged.to_a).to eq expected_merge
        end.to_not raise_error
      end
    end
  end
end
