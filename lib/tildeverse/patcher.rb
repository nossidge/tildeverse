#!/usr/bin/env ruby

module Tildeverse
  ##
  # Update user tags from 'dir_input' to 'dir_output'.
  #
  class Patcher
    ##
    # Update user tags from 'dir_input' to 'dir_output'.
    #
    # Run this after you have done manual user tagging in the input JSON.
    # It will update the output JSON without doing the full site-scrape.
    #
    # @return [Boolean] success state.
    #
    def patch
      return false unless write_permissions?

      # This is the JSON object that will be updated.
      tf = Tildeverse::Files
      output = tf.output_tildeverse

      # Only need to update the users that exist in the output file.
      tf.input_tildeverse['sites'].each do |site, site_hash|
        [*site_hash['users']].each do |user, user_hash|
          begin
            output['sites'][site]['users'][user]['tagged'] = user_hash['tagged']
            output['sites'][site]['users'][user]['tags']   = user_hash['tags']
          rescue NoMethodError
          end
        end
      end

      # Update the 'output' JSON.
      tf.save_json(output, tf.output_json_tildeverse)
      true
    end

    private

    ##
    # Check whether the current user has the correct OS permissions
    # to write to the output file.
    #
    # @return [Boolean]
    #
    def write_permissions?
      files = [
        Tildeverse::Files.output_json_tildeverse
      ]
      Tildeverse::Files.write?(files)
    end
  end
end
