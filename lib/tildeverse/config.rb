#!/usr/bin/env ruby

module Tildeverse
  #
  # Configuration of the files in the repo.
  module Config
    class << self
      def dir_root
        File.expand_path('../../../', __FILE__)
      end

      def dir_config
        "#{dir_root}/config"
      end

      def dir_data
        "#{dir_root}/data"
      end

      def dir_html
        "#{dir_root}/output"
      end

      def input_html_template
        "#{dir_data}/index_template.html"
      end

      def input_json_tildeverse
        "#{dir_data}/tildeverse.json"
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
        "#{dir_html}/index.html"
      end

      def output_json_users
        "#{dir_html}/users.json"
      end

      def output_json_tildeverse
        "#{dir_html}/tildeverse.json"
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
    end
  end
end
