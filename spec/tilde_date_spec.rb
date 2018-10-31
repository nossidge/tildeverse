#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::TildeDate' do
  let(:valid_data) do
    [
      {
        input:   '2018-11-01',
        to_s:    '2018-11-01',
        to_date: Date.new(2018, 11, 1)
      }, {
        input:   '20181101',
        to_s:    '2018-11-01',
        to_date: Date.new(2018, 11, 1)
      }, {
        input:   :nov2018,
        to_s:    '2018-11-01',
        to_date: Date.new(2018, 11, 1)
      }, {
        input:   Date.new(2018, 11, 1),
        to_s:    '2018-11-01',
        to_date: Date.new(2018, 11, 1)
      }, {
        input:   Tildeverse::TildeDate.new('2018-11-01'),
        to_s:    '2018-11-01',
        to_date: Date.new(2018, 11, 1)
      }, {
        input:   '-',
        to_s:    '-',
        to_date: Date.new(1970, 1, 1)
      }, {
        input:   Date.new(1970, 1, 1),
        to_s:    '-',
        to_date: Date.new(1970, 1, 1)
      }
    ]
  end

  describe '#new' do
    it 'should fail on invalid input' do
      ['2018-99-31', 'foo', 1, nil, String].each do |i|
        expect do
          Tildeverse::TildeDate.new(i)
        end.to raise_error(ArgumentError)
      end
    end
  end

  type_conv = proc do |class_type, message|
    describe "##{message}" do
      it "should return the correct #{class_type} object" do
        valid_data.each do |i|
          td = Tildeverse::TildeDate.new i[:input]
          expect(td.send(message)).to eq i[message]
        end
      end
    end
  end
  type_conv.call('Date',   :to_date)
  type_conv.call('String', :to_s)

  describe '#<=>' do
    it 'should be comparable with Date objects' do
      [
        [Tildeverse::TildeDate,  Tildeverse::TildeDate],
        [Tildeverse::TildeDate,  Date],
        [Date,                   Tildeverse::TildeDate]
      ].each do |klass1, klass2|
        one = klass1.parse '2018-10-01'
        two = klass2.parse '2018-10-02'
        expect(one <  two).to be true
        expect(one >  two).to be false
        expect(one == two).to be false
        expect(one <= two).to be true
        expect(one >= two).to be false
        expect(one != two).to be true
        one = klass1.parse '2018-10-01'
        two = klass2.parse '2018-10-01'
        expect(one == two).to be true
        expect(one <= two).to be true
        expect(one >= two).to be true
        expect(one != two).to be false
      end
    end
  end
end
