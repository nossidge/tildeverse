#!/usr/bin/env ruby

module Tildeverse
  ##
  # Fetch the up-to-date JSON file from the remote URI.
  #
  class Fetcher
    ##
    # Fetch the up-to-date JSON file from the remote URI.
    #
    # @return [Boolean] success state.
    #
    def fetch
      return false unless write_permissions?

      # Set up a connection to the remote JSON file.
      tf = Tildeverse::Files
      info = ['remote_json', tf.remote_json]
      remote = Tildeverse::RemoteResource.new(*info)

      # Try to get via HTTP, and return on failure.
      remote.get
      puts remote.msg or return false if remote.error?

      # Save the remote result verbatim, overwriting the existing JSON.
      tf.save_text(remote.result, tf.output_json_tildeverse)

      # Use the verbatim output JSON to append to the input JSON.
      update_input_from_output

      true
    end

    private

    ##
    # Check whether the current user has the correct OS permissions
    # to write to the output files.
    #
    # @return [Boolean]
    #
    def write_permissions?
      files = [
        Tildeverse::Files.output_json_tildeverse,
        Tildeverse::Files.input_json_tildeverse
      ]
      Tildeverse::Files.write?(files)
    end

    ##
    # Update the 'input' JSON from the 'output' JSON.
    # This seems a bit backward, but it makes sense, honest.
    #
    def update_input_from_output
      tf   = Tildeverse::Files
      from = tf.output_tildeverse
      to   = tf.input_tildeverse

      # Copy the metadata url.
      to['metadata']['url'] = from['metadata']['url']

      # Copy just the new users.
      from['sites'].each_key do |site|
        hash_to   = to  ['sites'][site]
        hash_from = from['sites'][site]

        # Copy the whole structure if the site doesn't already exist.
        if hash_to.nil?
          to['sites'][site] = from['sites'][site]
          next
        end

        # Update each user, if remote is more recent.
        update_input_users_from_output!(hash_to, hash_from)

        # Update the url fields.
        %w[url_root url_list url_format_user].each do |field|
          hash_to[field] = hash_from[field]
        end
      end

      # Update the 'input' JSON.
      tf.save_json(to, tf.input_json_tildeverse)
    end

    ##
    # Update each user. Changes the values of the hash inputs.
    #
    # @param [Hash] hash_to
    #   Hash to read from.
    # @param [Hash] hash_from
    #   Hash to write to.
    #
    def update_input_users_from_output!(hash_to, hash_from)
      hash_from['users'].each_key do |user|
        #
        # Copy the whole structure if the user doesn't already exist.
        # But don't get users that don't yet have tags.
        if hash_to['users'][user].nil?
          unless hash_from['users'][user]['tags'].nil?
            hash_to['users'][user] = hash_from['users'][user]
            hash_to['users'][user].delete('time')
          end
          next
        end

        # Only update the tags if the 'tagged' date is greater.
        tagged_to   = hash_to  ['users'][user]['tagged'] || '1970-01-01'
        tagged_from = hash_from['users'][user]['tagged'] || '1970-01-01'
        date_to     = Date.strptime(tagged_to,   '%Y-%m-%d')
        date_from   = Date.strptime(tagged_from, '%Y-%m-%d')
        hash_to['users'][user]['tagged'] = tagged_from if date_to < date_from
      end
    end
  end
end
