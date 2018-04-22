#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising a site full of users
  #
  # To be included by the {Site} class
  #
  module SiteSerializer
    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_for_output
      serialize(@users_online, 'output')
    end

    ##
    # Serialize the data for writing to {Files#input_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_for_input
      serialize(@users_tagged, 'input')
    end

    private

    ##
    # Serialize the data
    #
    # @param [Array<String>] users_array list of user names to display
    # @param [String] type either 'input' or 'output'
    #
    def serialize(users_array, type)
      raise ArgumentError unless %w[input output].include?(type)
      {}.tap do |h|
        h[:url_root]        = root
        h[:url_list]        = resource
        h[:url_format_user] = url_format_user
        h[:online]          = online?           if type == 'output'
        h[:user_count]      = users_array.count if type == 'output'
        h[:users]           = serialize_users(users_array, type)
      end
    end

    ##
    # @param [Array<String>] users_array list of user names to display
    # @param [String] type either 'input' or 'output'
    # @return [Hash]
    #
    def serialize_users(users_array, type)
      raise ArgumentError unless %w[input output].include?(type)
      {}.tap do |h|
        users_array.each do |user|
          h[user] = @all_users[user].send("serialize_#{type}")
        end
      end
    end
  end
end
