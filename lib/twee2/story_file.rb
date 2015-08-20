module Twee2
  class StoryFileNotFoundException < Exception; end

  class StoryFile
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
      File::read(filename).each_line do |line| # REFACTOR: switch this to using regular expressions, why not?
        if line =~ /^:: *([^\[]*?) *(\[(.*?)\])? *[\r\n]+$/
          @passages[current_passage = $1.strip] = { tags: ($3 || '').split(' '), content: '', exclude_from_output: false, pid: nil}
        elsif current_passage
          @passages[current_passage][:content] << line
        end
      end
      @passages.each_key{|k| @passages[k][:content].strip!} # Strip excessive trailing whitespace
      # Run each passage through a preprocessor, if required
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
      end
      # Extract 'special' passages and mark them as not being included in output
      @story_name, story_css, story_js, pid, story_start_pid = 'An unnamed story', '', '', 0, 1
      @passages.each_key do |k|
        if k == 'StoryTitle'
          @story_name = @passages[k][:content]
          @passages[k][:exclude_from_output] = true
        elsif %w{StorySubtitle StoryAuthor StoryMenu StorySettings StoryIncludes}.include? k
          puts "WARNING: ignoring passage '#{k}'"
          @passages[k][:exclude_from_output] = true
        elsif @passages[k][:tags].include? 'stylesheet'
          story_css << "#{@passages[k][:content]}\n"
          @passages[k][:exclude_from_output] = true
        elsif @passages[k][:tags].include? 'script'
          story_js << "#{@passages[k][:content]}\n"
          @passages[k][:exclude_from_output] = true
        elsif k == 'Start'
          @passages[k][:pid] = (pid += 1)
          story_start_pid = pid
        else
          @passages[k][:pid] = (pid += 1)
        end
      end
      # Generate XML in Twine 2 format
      @story_data = Builder::XmlMarkup.new
      # TODO: what is tw-storydata's "options" attribute for?
      @story_data.tag!('tw-storydata', { name: @story_name, startnode: story_start_pid, creator: 'Twee2', 'creator-version' => Twee2::VERSION, ifid: 'TODO', format: '{{STORY_FORMAT}}', options: '' }) do
        @story_data.style(story_css, role: 'stylesheet', id: 'twine-user-stylesheet', type: 'text/twine-css')
        @story_data.script(story_js, role: 'script', id: 'twine-user-script', type: 'text/twine-javascript')
        @passages.each do |k,v|
          unless v[:exclude_from_output]
            @story_data.tag!('tw-passagedata', { pid: v[:pid], name: k, tags: v[:tags].join(' ') }, v[:content])
          end
        end
      end
    end

    # Returns the title of this story
    def title
      @story_name
    end

    # Returns the rendered XML that represents this story
    def xmldata
      @story_data.target!
    end
  end
end