#!/usr/bin/env ruby

module Tildeverse
  #
  # Configuration of the files in the repo.
  module Config
    def self.dir_root
      File.expand_path('../../../', __FILE__)
    end

    def self.dir_data
      "#{dir_root}/data"
    end

    def self.dir_html
      "#{dir_root}/output"
    end

    def self.input_html_template
      "#{dir_data}/index_template.html"
    end

    def self.input_json_tildeverse
      "#{dir_data}/tildeverse.json"
    end

    def self.input_tildeverse
      JSON[
        File.read(
          input_json_tildeverse,
          external_encoding: 'utf-8',
          internal_encoding: 'utf-8'
        )
      ]
    end

    def self.output_html_index
      "#{dir_html}/index.html"
    end

    def self.output_json_users
      "#{dir_html}/users.json"
    end

    def self.output_json_tildeverse
      "#{dir_html}/tildeverse.json"
    end

    def self.output_tildeverse
      JSON[
        File.read(
          output_json_tildeverse,
          external_encoding: 'utf-8',
          internal_encoding: 'utf-8'
        )
      ]
    end

    def self.files_to_copy
      %w[users.js boxes.js pie.js]
    end
  end
end
