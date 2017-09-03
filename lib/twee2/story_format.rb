require 'json'

module Twee2
  class StoryFormatNotFoundException < Exception; end

  class StoryFormat
    # Loads the StoryFormat with the specified name
    def initialize(name)
      raise(StoryFormatNotFoundException) if !File::exists?(format_file_path = Twee2::buildpath("storyFormats/#{name}/format.js")) && !File::exists?(format_file_path = "#{name}/format.js")
      @name = name
      format_file = File::read(format_file_path)
      format_data = format_file.match(/(["'])source\1 *: *(["']).*?[^\\]\2/)[0]
      format_data_for_json = "\{#{format_data}\}"
      @source = JSON.parse(format_data_for_json)['source']
    end

    # Given a story file, injects it into the StoryFormat and returns the HTML results
    def compile
      @source\
        .gsub('%', '%%') \
        .gsub('{{STORY_NAME}}',   '%{STORY_NAME}')   \
        .gsub('{{STORY_DATA}}',   '%{STORY_DATA}')   \
        .gsub('{{STORY_FORMAT}}', '%{STORY_FORMAT}') \
      % {
        STORY_NAME:   Twee2::build_config.story_name,
        STORY_DATA:   Twee2::build_config.story_file.xmldata,
        STORY_FORMAT: @name,
      }
    end

    # Returns an array containing the known StoryFormat names
    def self.known_names
      Dir.open(Twee2::buildpath('storyFormats')).to_a.sort.reject{|d|d=~/^\./}.map do |name|
        format_file_path = Twee2::buildpath("storyFormats/#{name}/format.js")
        format_file = File::read(format_file_path)
        version = format_file.match(/(["'])version\1 *: *(["'])(.*?[^\\])\2/)[3]
        " * #{name} (#{version})"
      end
    end
  end
end
