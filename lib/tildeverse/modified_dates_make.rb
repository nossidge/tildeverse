#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Temporary solution to replace ~insom's list:
  # http://tilde.town/~insom/modified.html
  #
  # This will write the data in the exact same output format, to ease
  # the migration to a new solution
  #
  class ModifiedDatesMake

    # Make the file
    def make
      file = Files.dir_public + 'modified.html'
      Files.save_text(full_html, file)
    end

    private

    # @return [String] full HTML contents
    def full_html
      users_modified = users_modified_hash
      (+'').tap do |output|
        users_modified.keys.sort.reverse.each do |month|
          output << html_line_header(month) << "\n"
          users_modified[month].sort_by(&:last).reverse.each do |url, date|
            output << html_line_user(url, date) << "\n"
          end
        end
      end
    end

    # @return [Hash{String => Array<String, DateTime>}]
    def users_modified_hash
      Hash.new { |h, k| h[k] = [] }.tap do |hash|
        Tildeverse.users.each do |user|
          url = user.homepage
          date = last_modified_header(url)
          next unless date
          month = date.strftime('%Y-%m')
          hash[month] << [url, date]
        end
      end
    end

    # @param url [String] url to query
    # @return [DateTime] last modified date
    def last_modified_header(url)
      uri = URI(URI::encode(url))
      res = Net::HTTP.get_response(uri)
      return nil unless res['last-modified']
      DateTime.parse(res['last-modified'])
    end

    # @param url [String]
    # @param date [DateTime]
    # @return [String] HTML line for a URL and date
    def html_line_user(url, date)
      template = '<a href="URL">URL</a> -- DATE<br/>'
      template.gsub('URL', url).sub('DATE', date.strftime('%Y-%m-%dT%H:%M:%S'))
    end

    # @param yyyy_mm [String] month in the format 'YYYY-MM'
    # @return [String] HTML header line for a particular month
    def html_line_header(yyyy_mm)
      '<h2>YYYY_MM</h2>'.sub('YYYY_MM', yyyy_mm)
    end
  end
end
