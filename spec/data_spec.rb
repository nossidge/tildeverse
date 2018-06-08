#!/usr/bin/env ruby

describe 'Tildeverse::Data' do

  # Same info as Config class, but not tied to a file on the system.
  ConfigStruct = Struct.new(
    :update_type,
    :update_frequency,
    :generate_html,
    :updated_on
  ) do
    def generate_html?; generate_html; end
    def update; nil; end
  end

  def config
    ConfigStruct.new('scrape', 'week', false, '2018-06-08')
  end

  def instance
    Tildeverse::Data.new(config)
  end

  ##############################################################################

  it '#config' do
    expect(instance.config).to eq config
  end

  # This should include one object of each 'Sites' class.
  it '#sites' do
    sites = instance.sites.map(&:class)
    expect(sites).to eq Tildeverse::Sites.classes
  end

  it '#site' do
    data = instance
    site = data.site('pebble.ink')
    expect(site).to be_a Tildeverse::Sites::PebbleInk
    site = data.site('tilde.town')
    expect(site).to be_a Tildeverse::Sites::TildeTown
    site = data.site('foo-bar.example')
    expect(site).to be nil
  end

  it '#users' do
    users = instance.users
    expect(users).to all be_a Tildeverse::User
  end

  it '#user' do
    data = instance
    %w[nossidge imt foobar_no_name].each do |username|
      users = data.user(username)
      expect(users).to all be_a Tildeverse::User
      names = users.map(&:name)
      expect(names).to all eq username
    end
  end

  it '#save' do
    data = instance
    user = data.user('nossidge').first
    old_tags = user.tags
    new_tags = %w[bar foo]
    user.tags = new_tags
    expect(user.tags).to eq new_tags
    data.save
    user = data.user('nossidge').first
    expect(user.tags).to eq new_tags
    user.tags = old_tags
    data.save
    user = data.user('nossidge').first
    expect(user.tags).to eq old_tags
  end

  it '#save_website' do
    #
    # Should update the users JSON file, as well as the static web files.
    files_to_update = Tildeverse::Files.files_to_copy.map do |f|
      Tildeverse::Files.dir_output + f
    end
    files_to_update << Tildeverse::Files.output_json_users

    # Get hash of files to modified times.
    mod_times_hash = ->(files) do
      {}.tap do |hash|
        files.each do |f|
          hash[f] = f.mtime
        end
      end
    end
    old_mod_times = mod_times_hash.call(files_to_update)
    instance.save_website
    new_mod_times = mod_times_hash.call(files_to_update)

    # Make sure the mod times are newer.
    files_to_update.each do |f|
      expect(old_mod_times[f]).to be < new_mod_times[f]
    end
  end

  # Should always call '#save'.
  # Should only call '#save_website' if the config value is set.
  it '#save_with_config' do
    save_website = true
    config = ConfigStruct.new('scrape', 'week', save_website, '2018-06-08')
    data = Tildeverse::Data.new(config)
    expect(data).to receive(:save)
    expect(data).to receive(:save_website)
    data.save_with_config

    save_website = false
    config = ConfigStruct.new('scrape', 'week', save_website, '2018-06-08')
    data = Tildeverse::Data.new(config)
    expect(data).to receive(:save)
    expect(data).to_not receive(:save_website)
    data.save_with_config
  end

  # Call #user
  # Set new information about a user
  # Call #clear
  # Call #user (which will implicitly re-read from file if data empty)
  # Information should NOT have been saved
  it '#clear' do
    data = instance
    user = data.user('nossidge').first
    old_tags = user.tags
    new_tags = %w[bar foo]
    user.tags = new_tags
    expect(user.tags).to eq new_tags
    data.clear
    user = data.user('nossidge').first
    expect(user.tags).to eq old_tags
  end

  it '#serialize_users' do
    %w[nossidge imt foo].each do |username|
      users = instance.user(username)
      hash = instance.serialize_users(users)
      users.each do |user_obj|
        sitename = user_obj.site.name
        %i[tagged tags time].each do |i|
          expect(hash.dig(sitename, username, i)).to_not be nil
        end
      end
    end
  end

  it '#serialize_sites' do
    %w[pebble.ink tilde.town].each do |sitename|
      sites = instance.site(sitename)
      hash = instance.serialize_sites(sites)
      %i[url_root url_list url_format_user online user_count users].each do |i|
        expect(hash.dig(sitename, i)).to_not be nil
      end
    end
  end

  it '#serialize_tildeverse_json' do
    hash = instance.serialize_tildeverse_json
    expect(hash[:metadata]).to_not be nil
    %i[url date_human date_unix date_timezone].each do |i|
      expect(hash.dig(:metadata, i)).to_not be nil
    end
    expect(hash[:sites]).to eq instance.serialize_all_sites
  end

  it '#serialize_users_json' do
    hash = instance.serialize_users_json
    hash.each do |site, site_hash|
      expect(site).to be_a String
      site_hash.each do |user_name, user_url|
        expect(user_name).to be_a String
        expect(user_url).to be_a String
      end
    end
  end
end
