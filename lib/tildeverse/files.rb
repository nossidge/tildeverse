#!/usr/bin/env ruby

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
      # @return [Pathname] the template file for the HTML output.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/input/index_template.html'
      #
      def input_html_template
        dir_input + 'index_template.html'
      end

      ##
      # @return [Pathname] the input 'tildeverse' JSON file.
      # @example
      #   'C:/Dropbox/Code/Ruby/tildeverse/input/tildeverse.json'
      #
      def input_json_tildeverse
        dir_input + 'tildeverse.json'
      end

      ##
      # @return [Hash] the contents of {Files#input_json_tildeverse}.
      #
      def input_tildeverse
        JSON[
          File.read(
            input_json_tildeverse,
            external_encoding: 'utf-8',
            internal_encoding: 'utf-8'
          )
        ]
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
      # @return [Hash] the contents of {Files#output_json_tildeverse}.
      #
      def output_tildeverse
        JSON[
          File.read(
            output_json_tildeverse,
            external_encoding: 'utf-8',
            internal_encoding: 'utf-8'
          )
        ]
      rescue Errno::ENOENT
        {}
      end

      ##
      # @return [Array<String>]
      #   the files to directly copy from +/input/+ to +/output/+.
      # @example
      #   [
      #     'users.js',
      #     'boxes.js',
      #     'pie.js'
      #   ]
      #
      def files_to_copy
        %w[users.js boxes.js pie.js]
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
      # Determine if the current user has permission to write to the files.
      #
      # Writes error message to stdout if no permission granted.
      #
      # @param [Array<Pathname>] files
      #   Array of files to determine permissions for.
      # @return [Boolean]
      #
      def write?(files)
        faulty = files.reject(&:writable?)
        return true if faulty.empty?

        msg  = "You do not have permission to write to the output location.\n"
        msg += "Please contact your admin to get write access to:\n"
        msg += faulty.map(&:to_s).join("\n")
        puts msg
        false
      end

      ##
      # Save a hash to a JSON file.
      #
      # @param [String] hash_obj  Hash object to write to file.
      # @param [Pathname, String] filepath  Location to save file to.
      # @return [nil]
      #
      def save_json(hash_obj, filepath)
        File.open(filepath, 'w') do |f|
          f.puts JSON.pretty_generate(hash_obj).force_encoding('UTF-8')
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
          f.puts string.to_s.force_encoding('UTF-8')
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
            f.puts i.dup.force_encoding('UTF-8')
          end
        end
      end

      ##
      # Make a directory, or recursively make a directory structure.
      #
      # @param [Pathname, String] pathname  Directory to create.
      # @return [nil]
      #
      def makedirs(pathname)
        FileUtils.makedirs pathname
      end
    end
  end
end
