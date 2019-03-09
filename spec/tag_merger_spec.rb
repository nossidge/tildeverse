#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::TagMerger' do
  let(:config) { double('Config') }
  let(:data) { Tildeverse::Data.new(config) }
  let(:filepath) { Tildeverse::Files.input_txt_tildeverse_fetch_backup }
  let(:tag_merger) { Tildeverse::TagMerger.new(data, filepath) }
  let(:result) { tag_merger.merge }

  describe '#merge' do
    include_context 'before_each__seed_the_data'

    diffs = [
      {
        site: 'pebble.ink',
        user: 'contolini',
        from: 'empty',
        to:   'audio',
        date_from: Tildeverse::TildeDate.new('2017-09-01'),
        date_to:   Tildeverse::TildeDate.new('2017-09-02')
      }, {
        site: 'pebble.ink',
        user: 'ke7ofi',
        from: 'art',
        to:   %w[poetry video],
        date_from: Tildeverse::TildeDate.new('2017-09-01'),
        date_to:   Tildeverse::TildeDate.new('2018-09-01')
      }, {
        site: 'tilde.club',
        user: 'foo_user',
        from: 'empty',
        to:   'art',
        date_from: Tildeverse::TildeDate.new('2018-10-01'),
        date_to:   Tildeverse::TildeDate.new('2018-10-20')
      }
    ]

    it 'should update existing users with new tags' do
      ensure_tags_are = proc do |from_or_to|
        diffs.each do |i|
          user = data.site(i[:site]).user(i[:user])
          expect(user.tags).to eq [*i[from_or_to]]
        end
      end
      ensure_tags_are.call(:from)
      tag_merger.merge
      ensure_tags_are.call(:to)
    end

    it 'should retain correct #date_tagged values' do
      ensure_dates_are = proc do |date_from_or_to|
        diffs.each do |i|
          user = data.site(i[:site]).user(i[:user])
          expect(user.date_tagged).to eq i[date_from_or_to]
        end
      end
      ensure_dates_are.call(:date_from)
      tag_merger.merge
      ensure_dates_are.call(:date_to)
    end

    it 'should ignore existing users with older tags' do
      diffs = [
        {
          site: 'pebble.ink',
          user: 'clach04',
          from: 'empty',
          to:   'prose'
        }
      ]
      ensure_tags_unchanged = proc do
        diffs.each do |i|
          user = data.site(i[:site]).user(i[:user])
          expect(user.tags).to eq [*i[:from]]
        end
      end
      ensure_tags_unchanged.call
      tag_merger.merge
      ensure_tags_unchanged.call
    end

    it 'should ignore newly added users' do
      ensure_no_user = proc do
        user = data.site('tilde.club')&.user('bar_user')
        expect(user).to be_nil
      end
      ensure_no_user.call
      tag_merger.merge
      ensure_no_user.call
    end
  end
end
