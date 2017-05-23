gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
streamify = require 'gulp-streamify'

paths = sass: ['./scss/**/*.scss']

gulp.task 'default', ['coffee']

gulp.task 'coffee', ->
  browserify entries: ['./www/js/index.coffee']
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe source 'index.js'
    .pipe gulp.dest 'www/js'
    .pipe streamify uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest 'www/js'
