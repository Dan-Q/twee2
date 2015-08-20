Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "twee2/version"

# Prerequisites (managed by bundler)
require 'rubygems'
require 'bundler/setup'
require 'thor'
require 'json'
require 'builder'
require 'filewatcher'
require 'haml'
require 'coffee_script'

module Twee2
  # Constants
  DEFAULT_FORMAT = 'Harlowe'
  HAML_OPTIONS = {
    remove_whitespace: true
  }

  def self.build(input, output, options = {})
    # Read and parse format file
    format_file = File::read(buildpath("storyFormats/#{options[:format]}/format.js"))
    format_data = format_file.match(/(["'])source\1 *: *(["']).*?[^\\]\2/)[0]
    format_data_for_json = "\{#{format_data}\}"
    result = JSON.parse(format_data_for_json)['source']
    # Read and parse input file
    passages, current_passage = {}, nil
    File::read(input).each_line do |line| # REFACTOR: switch this to using regular expressions, why not?
      if line =~ /^:: *([^\[]*?) *(\[(.*?)\])? *[\r\n]+$/
        passages[current_passage = $1.strip] = { tags: ($3 || '').split(' '), content: '', exclude_from_output: false, pid: nil}
      elsif current_passage
        passages[current_passage][:content] << line
      end
    end
    passages.each_key{|k| passages[k][:content].strip!} # Strip excessive trailing whitespace
    # Run each passage through a preprocessor, if required
    passages.each_key do |k|
      # HAML
      if passages[k][:tags].include? 'haml'
        passages[k][:content] = Haml::Engine.new(passages[k][:content], HAML_OPTIONS).render
        passages[k][:tags].delete 'haml'
      end
      # Coffeescript
      if passages[k][:tags].include? 'coffee'
        passages[k][:content] = CoffeeScript.compile(passages[k][:content])
        passages[k][:tags].delete 'coffee'
      end
    end
    # Extract 'special' passages and mark them as not being included in output
    story_name, story_css, story_js, pid, story_start_pid = 'An unnamed story', '', '', 0, 1
    passages.each_key do |k|
      if k == 'StoryTitle'
        story_name = passages[k][:content]
        passages[k][:exclude_from_output] = true
      elsif %w{StorySubtitle StoryAuthor StoryMenu StorySettings StoryIncludes}.include? k
        puts "WARNING: ignoring passage '#{k}'"
        passages[k][:exclude_from_output] = true
      elsif passages[k][:tags].include? 'stylesheet'
        story_css << "#{passages[k][:content]}\n"
        passages[k][:exclude_from_output] = true
      elsif passages[k][:tags].include? 'script'
        story_js << "#{passages[k][:content]}\n"
        passages[k][:exclude_from_output] = true
      elsif k == 'Start'
        passages[k][:pid] = (pid += 1)
        story_start_pid = pid
      else
        passages[k][:pid] = (pid += 1)
      end
    end
    # Generate XML in Twine 2 format
    story_data = Builder::XmlMarkup.new
    # TODO: what is tw-storydata's "options" attribute for?
    story_data.tag!('tw-storydata', { name: story_name, startnode: story_start_pid, creator: 'Twee2', 'creator-version' => Twee2::VERSION, ifid: 'TODO', format: options[:format], options: '' }) do
      story_data.style(story_css, role: 'stylesheet', id: 'twine-user-stylesheet', type: 'text/twine-css')
      story_data.script(story_js, role: 'script', id: 'twine-user-script', type: 'text/twine-javascript')
      passages.each do |k,v|
        unless v[:exclude_from_output]
          story_data.tag!('tw-passagedata', { pid: v[:pid], name: k, tags: v[:tags].join(' ') }, v[:content])
        end
      end
    end
    # Produce output file
    result.gsub!('{{STORY_NAME}}', story_name)
    result.gsub!('{{STORY_DATA}}', story_data.target!)
    File::open(output, 'w') do |out|
      out.print result
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
    puts Dir.open(buildpath('storyFormats')).to_a.sort.reject{|d|d=~/^\./}.map{|f|" * #{f}"}.join("\n")
  end

  def self.help
    puts "Twee2 #{Twee2::VERSION}"
    puts File.read(buildpath('doc/usage.txt'))
  end

  def self.buildpath(path)
    File.join(File.dirname(File.expand_path(__FILE__)), "../#{path}")
  end
end
