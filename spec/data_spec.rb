#!/usr/bin/env ruby

# TODO

describe 'Tildeverse::Data' do
  def instance
    @instance ||= Tildeverse::Data.new
  end

  it '#updated_today?' do
    instance.updated_today?
  end

  it '#sites' do
    instance.sites
  end

  it '#site' do
    instance.site('pebble.ink')
  end

  it '#users' do
    instance.users
  end

  it '#user' do
    instance.user('nossidge')
  end

  it '#serialize_users' do
    users = instance.user('nossidge')
    instance.serialize_users(users)
  end

  it '#serialize_sites' do
    sites = instance.site('pebble.ink')
    instance.serialize_sites(sites)
  end

  it '#serialize_tildeverse_json' do
    instance.serialize_tildeverse_json
  end

  it '#serialize_users_json' do
    instance.serialize_users_json
  end
end
