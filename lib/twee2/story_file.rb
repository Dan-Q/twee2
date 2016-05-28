require 'rubygems'
require 'haml'
require 'coffee_script'
require 'sass'
require 'builder'

module Twee2
  class StoryFileNotFoundException < Exception; end

  class StoryFile
    attr_accessor :passages
    attr_reader :child_story_files

    HAML_OPTIONS = {
      remove_whitespace: true
    }
    Tilt::CoffeeScriptTemplate.default_bare = true # bare mode for HAML :coffeescript blocks
    COFFEESCRIPT_OPTIONS = {
      bare: true
    }

    # Loads the StoryFile with the given name
    def initialize(filename)
      raise(StoryFileNotFoundException) if !File::exists?(filename)
      @passages, current_passage = {}, nil
      @child_story_files = []

      # Load file into memory to begin with
      lines = File::read(filename).split(/\r?\n/)
      # First pass - go through and perform 'includes'
      i, in_story_includes_section = 0, false
      while i < lines.length
        line = lines[i]
        if line =~ /^:: *StoryIncludes */
          in_story_includes_section = true
        elsif line =~ /^::/
          in_story_includes_section = false
        elsif in_story_includes_section && (line.strip != '')
          child_file = line.strip
          # include a file here because we're in the StoryIncludes section
          if File::exists?(child_file)
            lines.push(*File::read(child_file).split(/\r?\n/)) # add it on to the end
            child_story_files.push(child_file)
          else
            puts "WARNING: tried to include file '#{line.strip}' via StoryIncludes but file was not found."
          end
        elsif line =~ /^( *)::@include (.*)$/
          # include a file here because an @include directive was spotted
          prefix, filename = $1, $2.strip
          if File::exists?(filename)
            lines[i,1] = File::read(filename).split(/\r?\n/).map{|l|"#{prefix}#{l}"} # insert in-place, with prefix of appropriate amount of whitespace
            i-=1 # process this line again, in case of ::@include nesting
          else
            puts "WARNING: tried to ::@include file '#{filename}' but file was not found."
          end
        end
        i+=1
      end
      # Second pass - parse the file
      lines.each do |line|
        if line =~ /^:: *([^\[]*?) *(\[(.*?)\])? *(<(.*?)>)? *$/
          @passages[current_passage = $1.strip] = { tags: ($3 || '').split(' '), position: $5, content: '', exclude_from_output: false, pid: nil}
        elsif current_passage
          @passages[current_passage][:content] << "#{line}\n"
        end
      end
      @passages.each_key{|k| @passages[k][:content].strip!} # Strip excessive trailing whitespace
      # Run each passage through a preprocessor, if required
      run_preprocessors
      # Extract 'special' passages and mark them as not being included in output
      story_css, pid, @story_js, @story_start_pid, @story_start_name = '', 0, '', nil, 'Start'
      @passages.each_key do |k|
        if k == 'StoryTitle'
          Twee2::build_config.story_name = @passages[k][:content]
          @passages[k][:exclude_from_output] = true
        elsif k == 'StoryIncludes'
          @passages[k][:exclude_from_output] = true # includes should already have been handled above
        elsif %w{StorySubtitle StoryAuthor StoryMenu StorySettings}.include? k
          puts "WARNING: ignoring passage '#{k}'"
          @passages[k][:exclude_from_output] = true
        elsif @passages[k][:tags].include? 'stylesheet'
          story_css << "#{@passages[k][:content]}\n"
          @passages[k][:exclude_from_output] = true
        elsif @passages[k][:tags].include? 'script'
          @story_js << "#{@passages[k][:content]}\n"
          @passages[k][:exclude_from_output] = true
        elsif @passages[k][:tags].include? 'twee2'
          eval @passages[k][:content]
          @passages[k][:exclude_from_output] = true
        else
          @passages[k][:pid] = (pid += 1)
        end
      end
      @story_start_pid = (@passages[@story_start_name] || {pid: 1})[:pid]
      # Generate XML in Twine 2 format
      @story_data = Builder::XmlMarkup.new
      # TODO: what is tw-storydata's "options" attribute for?
      @story_data.tag!('tw-storydata', {
                                        name: Twee2::build_config.story_name,
                                   startnode: @story_start_pid,
                                     creator: 'Twee2',
                         'creator-version' => Twee2::VERSION,
                                        ifid: Twee2::build_config.story_ifid,
                                      format: '{{STORY_FORMAT}}',
                                     options: ''
                      }) do
        @story_data.style(story_css, role: 'stylesheet', id: 'twine-user-stylesheet', type: 'text/twine-css')
        @story_data.script('{{STORY_JS}}', role: 'script', id: 'twine-user-script', type: 'text/twine-javascript')
        @passages.each do |k,v|
          unless v[:exclude_from_output]
            @story_data.tag!('tw-passagedata', { pid: v[:pid], name: k, tags: v[:tags].join(' '), position: v[:position] }, v[:content])
          end
        end
      end
    end

    # Returns the rendered XML that represents this story
    def xmldata
      data = @story_data.target!
      data.gsub('{{STORY_JS}}', @story_js)
    end

    # Runs HAML, Coffeescript etc. preprocessors across each applicable passage
    def run_preprocessors
      @passages.each_key do |k|
        # HAML
        if @passages[k][:tags].include? 'haml'
          @passages[k][:content] = Haml::Engine.new(@passages[k][:content], HAML_OPTIONS).render
          @passages[k][:tags].delete 'haml'
        end
        # Coffeescript
        if @passages[k][:tags].include? 'coffee'
          @passages[k][:content] = CoffeeScript.compile(@passages[k][:content], COFFEESCRIPT_OPTIONS)
          @passages[k][:tags].delete 'coffee'
        end
        # SASS / SCSS
        if @passages[k][:tags].include? 'sass'
          @passages[k][:content] =  Sass::Engine.new(@passages[k][:content], :syntax => :sass).render
        end
        if @passages[k][:tags].include? 'scss'
          @passages[k][:content] =  Sass::Engine.new(@passages[k][:content], :syntax => :scss).render
        end
      end
    end
  end
end