#!/usr/bin/env ruby

require 'pathname'

module Tildeverse
  #
  # Location of the files in the repo.
  module Files
    class << self
      def dir_root
        Pathname(__FILE__).dirname.parent.parent
      end

      def dir_config
        dir_root + 'config'
      end

      def dir_input
        dir_root + 'input'
      end

      def dir_output
        dir_root + 'output'
      end

      def input_html_template
        dir_input + 'index_template.html'
      end

      def input_json_tildeverse
        dir_input + 'tildeverse.json'
      end

      def input_tildeverse
        JSON[
          File.read(
            input_json_tildeverse,
            external_encoding: 'utf-8',
            internal_encoding: 'utf-8'
          )
        ]
      end

      def output_html_index
        dir_output + 'index.html'
      end

      def output_json_users
        dir_output + 'users.json'
      end

      def output_json_tildeverse
        dir_output + 'tildeverse.json'
      end

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

      def files_to_copy
        %w[users.js boxes.js pie.js]
      end

      def remote_json
        'https://tilde.town/~nossidge/tildeverse/tildeverse.json'
      end

      # Does the current user have permission to write to the files?
      def write?(files)
        faulty = files.reject(&:writable?)
        return true if faulty.empty?

        msg  = "You do not have permission to write to the output location.\n"
        msg += "Please contact your admin to get write access to:\n"
        msg += faulty.map(&:to_s).join("\n")
        puts msg
        false
      end
    end
  end
end
