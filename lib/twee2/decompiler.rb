unless Gem.win_platform?
  require 'rubygems'
  require 'open-uri'
  require 'nokogiri'

  module Twee2
    class DecompilationFailedException < Exception; end

    class Decompiler
      def self.decompile(url)
        result = ''
        # Load the compiled HTML and sanity-check it
        html = Nokogiri::HTML(open(url))
        raise(DecompilationFailedException, 'tw-storydata not found') unless storydata = html.at_css('tw-storydata')
        # Extract the tw-storydata#name (StoryTitle) and #startnode
        result << "::StoryTitle\n#{storydata[:name].strip}\n\n"
        startnode_pid, startnode_name = storydata[:startnode].strip, nil
        # Extract the custom CSS and Javascript, if applicable
        if (css = storydata.at_css('#twine-user-stylesheet')) && ((css_content = css.content.strip) != '')
          result << "::StoryCSS [stylesheet]\n#{css_content}\n\n"
        end
        if (js = storydata.at_css('#twine-user-script')) && ((js_content = js.content.strip) != '')
          result << "::StoryJS [script]\n#{js.content}\n\n"
        end
        # Extract each passage
        storydata.css('tw-passagedata').each do |passagedata|
          # Check if this is the start passage and record this accordingly
          startnode_name = passagedata[:name] if(startnode_pid == passagedata[:pid])
          # Write the passage out
          result << "::#{passagedata[:name].strip}"
          result << " [#{passagedata[:tags].strip}]" if passagedata[:tags].strip != ''
          result << " <#{passagedata[:position].strip}>" if passagedata[:position].strip != ''
          result << "\n#{tidyup_passagedata(passagedata.content.strip)}\n\n"
        end
        # Write the Twee2 settings out (compatability layer)
        result << "::Twee2Settings [twee2]\n"
        result << "@story_start_name = '#{startnode_name.gsub("'", "\\'")}'\n" if startnode_name
        result << "\n"
        # Return the result
        result
      end

      protected

      # Fixes common problems with decompiled passage content
      def self.tidyup_passagedata(passagedata_content)
        passagedata_content.gsub(/\[\[ *(.*?) *\]\]/, '[[\1]]').                # remove excess spacing within links: not suitable for Twee-style source
                            gsub(/\[\[ *(.*?) *<- *(.*?) *\]\]/, '[[\1<-\2]]'). # ditto
                            gsub(/\[\[ *(.*?) *-> *(.*?) *\]\]/, '[[\1->\2]]'). # ditto
                            gsub(/\[\[ *(.*?) *\| *(.*?) *\]\]/, '[[\1|\2]]')   # ditto
      end
    end
  end
end