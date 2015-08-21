module Twee2
  class StoryFormatNotFoundException < Exception; end

  class StoryFormat
    # Loads the StoryFormat with the specified name
    def initialize(name)
      raise(StoryFormatNotFoundException) if !File::exists?(format_file_path = Twee2::buildpath("storyFormats/#{name}/format.js"))
      @name = name
      format_file = File::read(format_file_path)
      format_data = format_file.match(/(["'])source\1 *: *(["']).*?[^\\]\2/)[0]
      format_data_for_json = "\{#{format_data}\}"
      @source = JSON.parse(format_data_for_json)['source']
    end

    # Given a story file, injects it into the StoryFormat and returns the HTML results
    def compile
      @source.gsub('{{STORY_NAME}}', Twee2::build_config.story_name).gsub('{{STORY_DATA}}', Twee2::build_config.story_file.xmldata).gsub('{{STORY_FORMAT}}', @name)
    end

    # Returns an array containing the known StoryFormat names
    def self.known_names
      Dir.open(Twee2::buildpath('storyFormats')).to_a.sort.reject{|d|d=~/^\./}.map{|f|" * #{f}"}
    end
  end
end
