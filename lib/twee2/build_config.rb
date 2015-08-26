require 'singleton'
require 'securerandom'

module Twee2
  class BuildConfig
    include Singleton

    attr_accessor :story_format, :story_file, :story_name
    attr_reader :story_ifid, :story_ifid_specified

    # Set defaults
    def initialize
      @story_name = 'An unnamed story'
      @story_ifid, @story_ifid_specified = SecureRandom.uuid, false
    end

    # Set the IFID - we track when this occurs so that the user can be
    # nagged for not manually setting it
    def story_ifid=(value)
      @story_ifid = value
      @story_ifid_specified = true
    end
  end

  def self.build_config
    BuildConfig::instance
  end
end