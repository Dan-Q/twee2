# Twee2

Command-line tool to compile Twee-style (.tw, .twine) interactive fiction source files to [Twine 2](http://twinery.org/)-style output. Use your favourite text editor to write Twine 2 interactive fiction.

Designed for those who preferred the Twee approach to source management, because the command-line is awesome, but who want to take advantage of the new features in Twine 2. With a little work, this tool may also function as a partial Twine 1 to Twine 2 converter.

For installation and usage, see https://dan-q.github.io/twee2/

## Philosophy

(Why does this exist? Where is it going?)

I love the direction that Twine 2 has been going in, in regard to ditching the old Tiddlywiki backend and making it easier than ever for developers to integrate their own CSS and Javascript into their stories. However, as a fan of plain-old text editors and not of IDEs, I'm not so keen on the fact that it's now almost-impossible to develop a Twine adventure from the command-line only (there's no "Twee" equivalent for Twine 2). For my own benefit and enjoyment, I aim to fill that gap. If it helps you too, then that's just a bonus.

I'd love to hear your thoughts about the future of this gem. Pull requests are also welcome.

## Installation

Install using gem

    gem install twee2

* [Full installation instructions](https://dan-q.github.io/twee2/install.html).

For errors involving nokogiri, see [Installing Nokogiri](http://www.nokogiri.org/tutorials/installing_nokogiri.html).

## Basic Usage

To compile a Twee file into a HTML file using the default format (Harlowe):

    twee2 build inputfile.twee outputfile.html

To use a specific format, e.g. Snowman:

    twee2 build inputfile.twee outputfile.html --format=Snowman

For additional features (e.g. listing known formats, watch-for-changes mode), run twee2 without any parameters. Or see the full documentation at https://dan-q.github.io/twee2/documentation.html.

## Special features

Aside from the obvious benefits of a "use your own editor" solution, Twee2 provides the following enhancements over Twine 2:

* Multi-file inclusion - spread your work over multiple files to improve organisation, facilitate better source control, collaborate with others, or make re-usable modules.
* [HAML](http://haml.info/) support - for those who prefer HAML to Markdown, and for advanced embedding of scripting into passages.
* [Coffeescript](http://coffeescript.org/) transpiler - optionally write your Javascript in Coffeescript for a smarter, lighter syntax.
* [SASS/SCSS](http://sass-lang.com/) stylesheets - optionally enhance your CSS with syntactic awesome.
* Ruby-powered dynamic generation - automate parts of your build chain (e.g. how about a procedurally-built maze of twisty little passages... or even something actually *good*) with Ruby scripting
* Twine 2 decompilation - reverse-engineer Twine 2 stories into Twee2 source code to convert your projects or to understand other people's.

## Notes

* This is not a Twee to Harlowe converter. You'll still need to change your macros as described at http://twine2.neocities.org/, and/or rewrite them as Javascript code. However, it might help your efforts to update Twee sources to Twine 2 output.
* Some special story segments (e.g. StorySubtitle) used in Twee 1 are ignored. You will be warned when this happens.
* The Twine 2 editor might not be able to re-open stories compiled using Twee2, because Twee2 does not automatically include positional data used by the visual editor (however, you can add this manually if you like).

## Build

To build a local copy of the gem:

	gem build twee2.gemspec

To install it locally (e.g., for version number 0.5.0):

	gem install twee2-0.5.0.gem

## License

This code is released under the GPL, version 2. It includes code (in the storyFormats directory) by other authors, including Leon Arnott: please read their licenses before redistributing.
