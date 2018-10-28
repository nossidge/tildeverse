#!/usr/bin/env ruby
# frozen_string_literal: true

describe 'Tildeverse::TagMerger' do
  let(:config) { double('Config') }
  let(:data) { Tildeverse::Data.new(config) }
  let(:tag_merger) { Tildeverse::TagMerger.new(data) }
  let(:result) { tag_merger.merge }

  describe '#merge' do
    include_context 'before_each__seed_the_data'

    it 'should update existing users with new tags' do
      diffs = [
        {
          site: 'pebble.ink',
          user: 'contolini',
          from: 'empty',
          to:   'audio'
        }, {
          site: 'pebble.ink',
          user: 'ke7ofi',
          from: 'art',
          to:   %w[poetry video]
        }, {
          site: 'tilde.club',
          user: 'foo_user',
          from: 'empty',
          to:   'art'
        }
      ]
      ensure_tags_are = proc do |from_or_to|
        diffs.each do |i|
          user = data.site(i[:site]).user(i[:user])
          expect(user.tags).to eq [*i[from_or_to]]
        end
      end
      ensure_tags_are[:from]
      tag_merger.merge
      ensure_tags_are[:to]
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
