module.exports = function(grunt) {

  grunt.initConfig({
    run: {
      twee2: {
        exec: 'bundle exec twee2 build story.tw2 story.html'
      }
    },
    watch: {
      files: ['*.tw2', 'stylesheets/*.tw2', 'javascripts/*.tw2', 'sections/*.tw2'],
      tasks: ['run:twee2'],
      livereload: {
        options: { livereload: true },
        files: ['story.html'],
      },
    },
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-run');

};
