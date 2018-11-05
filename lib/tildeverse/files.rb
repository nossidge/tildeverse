#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'json'

module Tildeverse
  ##
  # Location of the input and output files in the repository.
  #
  module Files
    class << self
      ##
      # @return [Pathname] the root directory of the repository.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse'
      #
      def dir_root
        Pathname(__FILE__).dirname.parent.parent
      end

      ##
      # @return [Pathname] the directory for input data files.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/input'
      #
      def dir_input
        dir_root + 'input'
      end

      ##
      # @return [Pathname] the directory for output data files.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/output'
      #
      def dir_output
        dir_root + 'output'
      end

      ##
      # File path of the config YAML. Creates directory if not yet existing.
      # @return [Pathname] the file path of the config YAML
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/config/config.yml'
      #
      def config_yml
        dir_config = dir_root + 'config'
        FileUtils.makedirs(dir_config) unless dir_config.exist?
        dir_config + 'config.yml'
      end

      ##
      # @return [Pathname] the input 'tildeverse' TXT file.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/input/tildeverse.txt'
      #
      def input_txt_tildeverse
        dir_input + 'tildeverse.txt'
      end

      ##
      # Read in the contents of 'tildeverse.txt' and parse to a Hash
      #
      # @return [Hash]
      # @example
      #   {
      #     'tilde.town' => {
      #       'karlen' => {
      #         :date_online => '2018-04-01',
      #         :date_offline => '-',
      #         :date_modified => '2017-12-04',
      #         :date_tagged => '2018-03-10',
      #         :tags => [
      #           'art',
      #           'audio'
      #         ]
      #       },
      #       'nossidge' => {
      #         :date_online => '2018-04-01',
      #         :date_offline => '-',
      #         :date_modified => '2017-04-02',
      #         :date_tagged => '2017-08-14',
      #         :tags => [
      #           'art',
      #           'audio',
      #           'gaming',
      #           'poetry',
      #           'procgen',
      #           'prose',
      #           'tilde',
      #           'web1.0'
      #         ]
      #       },
      #       'untagged_john_doe' => {
      #         :date_online => '2018-05-02',
      #         :date_offline => '-',
      #         :date_modified => '-',
      #         :date_tagged => '-',
      #         :tags => []
      #       }
      #     }
      #   }
      #
      def input_tildeverse_txt_as_hash
        return @input_tildeverse_txt_as_hash if @input_tildeverse_txt_as_hash

        file = input_txt_tildeverse
        FileUtils.touch(file) unless file.exist?
        file_contents = read_utf8(file)
        wsv = WSV.new(file_contents.split("\n"))

        # Convert the 'tags' property to an array.
        hash_array = wsv.from_wsv_with_header.tap do |a|
          a.each do |i|
            i[:tags] ||= ''
            i[:tags] = i[:tags].split(',')
          end
        end

        # Return in the format 'hash[site][user] => { user details }'
        @input_tildeverse_txt_as_hash = {}.tap do |h|
          hash_array.each do |i|
            site = i[:site_name]
            user = i[:user_name]
            h[site] ||= {}
            h[site][user] = {
              date_online:   i[:date_online],
              date_offline:  i[:date_offline],
              date_modified: i[:date_modified],
              date_tagged:   i[:date_tagged],
              tags:          i[:tags] || []
            }
          end
        end
      end

      ##
      # @return [Pathname]
      #   the temporary backup file that is created and deleted when a
      #   {Fetcher#fetch} operation is performed.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/input/tildeverse_fetch_backup.txt'
      #
      def input_txt_tildeverse_fetch_backup
        dir_input + 'tildeverse_fetch_backup.txt'
      end

      ##
      # @return [Pathname] the HTML output file.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/output/index.html'
      #
      def output_html_index
        dir_output + 'index.html'
      end

      ##
      # The path to the output 'users' JSON file.
      #
      # This is created for backwards-compatibility for external services
      # that use this instead of the newer {Files#output_json_tildeverse} file.
      #
      # @return [Pathname] the output 'users' JSON file.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/output/users.json'
      #
      def output_json_users
        dir_output + 'users.json'
      end

      ##
      # @return [Pathname] the output 'tildeverse' JSON file.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/output/tildeverse.json'
      #
      def output_json_tildeverse
        dir_output + 'tildeverse.json'
      end

      ##
      # @return [Pathname] the output 'tildeverse' TXT file.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/output/tildeverse.txt'
      #
      def output_txt_tildeverse
        dir_output + 'tildeverse.txt'
      end

      ##
      # @return [Hash] the contents of {Files#output_json_tildeverse}
      #
      def output_tildeverse!
        @output_tildeverse = begin
          JSON[
            read_utf8(output_json_tildeverse)
          ]
        rescue Errno::ENOENT
          {}
        end
      end

      ##
      # Same as {Files#output_tildeverse!}, but result is cached.
      #
      # @return [Hash] the contents of {Files#output_json_tildeverse}
      #
      def output_tildeverse
        @output_tildeverse ||= output_tildeverse!
      end

      ##
      # @return [Array<String>]
      #   the files to directly copy from +/input/+ to +/output/+.
      # @example
      #   [
      #     'index.html',
      #     'users.js',
      #     'boxes.js',
      #     'pie.js'
      #   ]
      #
      def files_to_copy
        %w[index.html users.js boxes.js pie.js tildeverse.txt]
      end

      ##
      # @return [String] the location of the remote +tildeverse.json+ file.
      #   This is updated every hour.
      # @example
      #   'https://tilde.town/~nossidge/tildeverse/tildeverse.json'
      #
      def remote_json
        'https://tilde.town/~nossidge/tildeverse/tildeverse.json'
      end

      ##
      # @return [String] the location of the remote +tildeverse.txt+ file.
      #   This is updated every hour.
      # @example
      #   'https://tilde.town/~nossidge/tildeverse/tildeverse.txt'
      #
      def remote_txt
        'https://tilde.town/~nossidge/tildeverse/tildeverse.txt'
      end

      ##
      # Save an object to a JSON file.
      #
      # @param [Hash, Array] obj  Object to write to file.
      # @param [Pathname, String] filepath  Location to save file to.
      # @return [nil]
      #
      def save_json(obj, filepath)
        File.open(filepath, 'w') do |f|
          f.puts JSON.pretty_generate(obj).force_encoding('UTF-8')
        end
      end

      ##
      # Save a string to a text file.
      #
      # @param [String] string  String to write to file.
      # @param [Pathname, String] filepath  Location to save file to.
      # @return [nil]
      #
      def save_text(string, filepath)
        File.open(filepath, 'w') do |f|
          f.puts string.to_s.dup.force_encoding('UTF-8')
        end
      end

      ##
      # Save an array to a text file, separated by newlines.
      #
      # @param [Array] array  Array to write to file.
      # @param [Pathname, String] filepath  Location to save file to.
      # @return [nil]
      #
      def save_array(array, filepath)
        File.open(filepath, 'w') do |f|
          array.each do |i|
            f.puts i.to_s.dup.force_encoding('UTF-8')
          end
        end
      end

      ##
      # Read a text file ensuring UTF8 encoding.
      #
      # @param [Pathname, String] filepath  Location of input file.
      # @return [String] File contents.
      #
      def read_utf8(filepath)
        File.read(
          filepath,
          external_encoding: 'utf-8',
          internal_encoding: 'utf-8'
        )
      end
    end
  end
end
