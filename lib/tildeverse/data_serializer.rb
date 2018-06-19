#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising data at a high level
  #
  # To be included by the {Data} class
  #
  module DataSerializer
    ##
    # Serialise an array of users to a hash, with site name as the key,
    # then user name, then user details
    #
    # @param [Array<User>] users
    # @return [Hash{String => Hash{String => User}}]
    #
    def serialize_users(users)
      DataSerializerClass.new(self).serialize_users(users)
    end

    ##
    # Serialise an array of sites to a hash, with site name as the key,
    # then user name, then user details
    #
    # @param [Array<Site>] sites
    # @return [Hash{String => Site#serialize_output}]
    #
    def serialize_sites(sites)
      DataSerializerClass.new(self).serialize_sites(sites)
    end

    ##
    # Serialise all sites in the sites_hash
    #
    # @return [Hash{String => Site#serialize_output}]
    #
    def serialize_all_sites
      DataSerializerClass.new(self).serialize_all_sites
    end

    ##
    # Serialize data in the format of {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_tildeverse_json
      DataSerializerClass.new(self).serialize_tildeverse_json
    end

    ##
    # Serialize data in the format of {Files#output_json_users}
    #
    # @return [Hash]
    #
    def serialize_users_json
      DataSerializerClass.new(self).serialize_users_json
    end

    ##
    # Serialize all users as an array of WSV formatted strings,
    # including a header row
    #
    # @return [Array<String>]
    #
    def serialize_tildeverse_txt
      DataSerializerClass.new(self).serialize_tildeverse_txt
    end
  end
end
