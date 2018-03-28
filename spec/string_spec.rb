#!/usr/bin/env ruby

describe 'String' do
  it '#remove_trailing_slash' do
    [
      {
        in:  'http://tilde.town/',
        out: 'http://tilde.town'
      },{
        in:  'http://tilde.town',
        out: 'http://tilde.town'
      },{
        in:  'http://tilde.town//',
        out: 'http://tilde.town/'
      },{
        in:  '',
        out: ''
      }
    ].each do |i|
      result = i[:in].remove_trailing_slash
      expect(result).to eq i[:out]
    end
  end

  it '#first_between_two_chars' do
    phrase = 'what a "silly" billy'
    [
      {
        char: '"',
        out:  'silly'
      },{
        char: 'a',
        out:  't '
      },{
        char: 'i',
        out:  'lly" b'
      },{
        char: 'l',
        out:  ''
      },{
        char: 'll',
        out:  'y" bi'
      },{
        char: 'y',
        out:  '" bill'
      },{
        char: ' ',
        out:  'a'
      },{
        char: 'w',
        out:  nil
      },{
        char: 'h',
        out:  nil
      },{
        char: '?',
        out:  nil
      }
    ].each do |i|
      result = phrase.first_between_two_chars(i[:char])
      expect(result).to eq i[:out]
    end
  end
end
