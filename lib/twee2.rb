Encoding.default_external = Encoding.default_internal = Encoding::UTF_8

# Prerequisites (managed by bundler)
%w{rubygems haml singleton
  twee2/version twee2/story_format twee2/story_file twee2/decompiler twee2/build_config
  bundler/setup
  thor json builder filewatcher coffee_script nokogiri open-uri sass}.each do |prerequisite|
  require prerequisite
end

module Twee2
  # Constants
  DEFAULT_FORMAT = 'Harlowe'

  def self.build(input, output, options = {})
    # Read and parse format file
    build_config.story_format = StoryFormat::new(options[:format])
    # Read and parse input file
    build_config.story_file = StoryFile::new(input)
    # Produce output file
    File::open(output, 'w') do |out|
      out.print build_config.story_format.compile
    end
    puts "Done"
  end

  def self.watch(input, output, options = {})
    puts "Compiling #{output}"
    build(input, output, options)
    puts "Watching #{input}"
    FileWatcher.new(input).watch do
      puts "Recompiling #{output}"
      build(input, output, options)
    end
  end

  def self.formats
    puts "I understand the following output formats:"
    puts StoryFormat.known_names.join("\n")
  end

  # Reverse-engineers a Twee2/Twine 2 output HTML file into a Twee2 source file
  def self.decompile(url, output)
    File::open(output, 'w') do |out|
      out.print Decompiler::decompile(url)
    end
    puts "Done"
  end

  def self.help
    puts "Twee2 #{Twee2::VERSION}"
    puts File.read(buildpath('doc/usage.txt'))
  end

  def self.buildpath(path)
    File.join(File.dirname(File.expand_path(__FILE__)), "../#{path}")
  end
end
