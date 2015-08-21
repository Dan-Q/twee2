module Twee2
  class BuildConfig
    include Singleton

    attr_accessor :story_format, :story_file, :story_name

    # Set defaults
    def initialize
      @story_name = 'An unnamed story'
    end
  end

  def self.build_config
    BuildConfig::instance
  end
end