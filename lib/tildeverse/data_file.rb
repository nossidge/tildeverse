#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'core_extensions/pathname'

module Tildeverse
  ##
  # One problem with saving to file is how to recover if the save is
  # interrupted in some way, or if the data file becomes corrupted.
  # A partial solution to this is to keep backups of previous files.
  #
  # The point of this class is to find the best file to read from, from
  # these backups. It does this in a fairly obvious manner; since the most
  # common sign of malformed data is truncation, it finds the most recent
  # file with the longest line-count.
  #
  # After {#get} has been called, the identified correct file will be used
  # to overwrite the existing +tildeverse.txt+ file and the backup file for
  # today's date, and any other backup files will be deleted.
  #
  # Thus, the final contents of the +/data/+ directory will be two identical
  # files with the below file names:
  #   tildeverse.txt
  #   tildeverse_yyyymmdd.txt  (today's date)
  #
  # Note: Since this is purely based on line count, it assumes that the text
  # file will only increase in user count, which will occur during normal
  # program execution. If there is a need to manually alter the text file,
  # then you should make sure that all other backup files are deleted,
  # to avoid the new file being accidentally overwritten.
  #
  class DataFile
    ##
    # @return [Pathname] the directory containing the data text files
    #
    attr_reader :dir

    ##
    # @param dir [Pathname] the directory containing the data text files
    # @example
    #   DataFile.new(Files.dir_data)
    #
    def initialize(dir = Files.dir_data)
      @dir = Pathname.new(dir)
    end

    ##
    # @return [Pathname] the 'main' Tildeverse text file
    #
    def main
      dir + 'tildeverse.txt'
    end

    ##
    # Side effects: if the user is authorised for write access,
    # 'tildeverse.txt' and 'tildeverse_yyyymmdd.txt' for today's
    # date will be overwritten with copies of the best file.
    # All other old backups will be deleted from the directory.
    #
    # @return [Pathname]
    #   the most recent, longest file. (i.e. if two files have the same
    #   line count, the most recent one is considered the best)
    #
    # @raise [Error::MissingFileError] if a valid file is not found
    #
    def get!
      best_file = all_files.max_by { |f| f.each_line.count }
      best_file ||= main

      dodgy_file = !best_file.exist? || best_file.zero?
      raise Error::MissingFileError, dir if dodgy_file

      if config_authorised?
        save_best_file(best_file)
        best_file = main
      end

      best_file
    end

    private

    ##
    # (see Tildeverse::Config#authorised?)
    #
    def config_authorised?
      Tildeverse.data.config.authorised?
    end

    ##
    # 'tildeverse.txt' and 'tildeverse_yyyymmdd.txt' for today's
    # date will be overwritten with copies of the best file.
    # All other old backups will be deleted from the directory.
    #
    # @param best_file [Pathname] the file containing the best data
    #
    def save_best_file(best_file)
      FileUtils.cp(best_file, todays_file) unless best_file == todays_file
      FileUtils.cp(best_file, main)        unless best_file == main

      files_to_kill = dir.glob('tildeverse_20??????.txt')
      files_to_kill.delete(todays_file)
      files_to_kill.each { |f| FileUtils.rm(f) }
    end

    ##
    # @return [Array<Pathname>]
    #   all Tildeverse text files, sorted from most to least recent.
    #   Sorting uses the timestamp in the file name, not the real modified date
    #
    def all_files
      dir.glob('tildeverse_20??????.txt').reverse.tap do |files|
        files.unshift(main) if main.exist?
      end
    end

    ##
    # @return [Pathname] the filepath of today's backup file
    #
    def todays_file
      date = Time.now.strftime('%Y%m%d')
      dir + "tildeverse_#{date}.txt"
    end
  end
end
