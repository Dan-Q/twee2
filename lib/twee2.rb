# Prerequisites (managed by bundler)
require 'rubygems'
require 'bundler/setup'
Dir.glob("#{File.dirname(File.absolute_path(__FILE__))}/twee2/*.rb", &method(:require))
require 'thor'
require 'filewatcher'

module Twee2
  # Constants
  DEFAULT_FORMAT = 'Harlowe'

  def self.build(input, output, options = {})
    # Read and parse input file
    begin
      build_config.story_file = StoryFile::new(input)
    rescue StoryFileNotFoundException
      puts "ERROR: story file '#{input}' not found."
      exit
    end
    # Read and parse format file, unless already set (by a Twee2::build_config.story_format call in the story file, for example)
    if !build_config.story_format
      begin
        build_config.story_format = StoryFormat::new(options[:format])
      rescue StoryFormatNotFoundException
        puts "ERROR: story format '#{options[:format]}' not found."
        exit
      end
    end
    # Load story format, if for some reason Twee2::build_config.story_format is set to a string rather than an instance
    if build_config.story_format.is_a?(String)
      new_format = build_config.story_format
      begin
        build_config.story_format = StoryFormat::new(new_format)
      rescue StoryFormatNotFoundException
        puts "ERROR: story format '#{new_format}' not found."
        exit
      end
    end
    # Warn if IFID not specified
    if !build_config.story_ifid_specified
      puts "NOTICE: You haven't specified your IFID. Consider adding to your code -"
      puts "::StoryIFID[twee2]\nTwee2::build_config.story_ifid = '#{build_config.story_ifid}'"
    end
    # Produce output file
    File::open(output, 'w') do |out|
      out.print build_config.story_format.compile
    end
    puts "Done"
  end

  def self.watch(input, output, options = {})
    puts "Compiling #{output}"
    build(input, output, options)
    puts "Watching #{input} and included children"
    watch_files = build_config.story_file.child_story_files
    watch_files.unshift(input)
    FileWatcher.new(watch_files).watch do |filename|
      puts "#{filename} changed. Recompiling #{output}"
      build(input, output, options)
    end
  end

  def self.formats
    puts "I understand the following output formats:"
    puts StoryFormat.known_names.join("\n")
  end

  def self.version_check
    `gem list -r -q twee2` =~ /\((.*)\)/
    puts "   Your version: #{Twee2::VERSION}"
    puts " Latest version: #{$1}"
    if Twee2::VERSION.to_s != $1
      puts "To upgrade, run: gem install twee2"
    end
  end

  unless Gem.win_platform?
    # Reverse-engineers a Twee2/Twine 2 output HTML file into a Twee2 source file
    def self.decompile(url, output)
      File::open(output, 'w') do |out|
        out.print Decompiler::decompile(url)
      end
      puts "Done"
    end
  end

  def self.help
    puts "Twee2 #{Twee2::VERSION}"
    puts File.read(buildpath('doc/usage.txt'))
  end

  def self.buildpath(path)
    File.join(File.dirname(File.expand_path(__FILE__)), "../#{path}")
  end
end
