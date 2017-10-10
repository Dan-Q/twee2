require 'spec_helper'
require 'pry'

RSpec.describe 'Twee2', type: :feature do
  context 'creating a twine story with the default format' do
    before(:all) do
      Twee2.build('spec/lib/story.tw2', 'spec/tmp/story.html', format: Twee2::DEFAULT_FORMAT)
    end

    it 'should create the html file specified in the output' do
      expect(File.exist?('spec/tmp/story.html')).to eq true
    end

    describe 'setting up the correct HTML/CSS/JS' do
      before(:all) do
        @html = Nokogiri::HTML(File.read('spec/tmp/story.html'))
      end

      it 'should set the correct title' do
        expect(@html.css('title').text).to eq 'Fancy Title'
      end

      it 'should have our custom CSS' do
        styles = @html.css('style')
        expect(styles.text).to include 'background-color: darkblue'
      end

      it 'should have our custom JS' do
        custom_script = @html.css('#twine-user-script')
        expect(custom_script.text).to include "console.log('not much happening in this story so far')"
      end

      it 'should have our story passages' do
        expect(@html.css('tw-storydata')).to_not be_nil
        expect(@html.css('tw-passagedata').length).to eq 3
        expect(@html.css('tw-passagedata').first.text).to eq 'You are [[here]].'
      end

      it 'should parse HAML correctly' do
        expect(@html.css('tw-passagedata').last.text).to include '<p><li>Or maybe you are? Go back to [[start]]</li></p>'
      end

      it 'should parse SASS correctly' do
        styles = @html.css('style')
        expect(styles.text).to include 'background-color: darkgreen'
      end

      it 'should parse CS correctly into the JS' do
        custom_script = @html.css('#twine-user-script')
        expect(custom_script.text).to include 'var csAddNumbers'
        expect(custom_script.text).to include 'csAddNumbers = function(x, y)'
        expect(custom_script.text).to include 'return x + y'
      end
    end
  end
end
