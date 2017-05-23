gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
streamify = require 'gulp-streamify'
cssToJs = require 'gulp-css-to-js'
concat = require 'gulp-concat'

gulp.task 'default', ['coffee']

gulp.task 'css', ->
  gulp.src 'node_modules/rc-tree/assets/index.css'
    .pipe cssToJs()
    .pipe concat 'css.js'
    .pipe gulp.dest 'www/js'

gulp.task 'coffee', ['css'],  ->
  browserify entries: ['./www/js/index.coffee']
    .transform 'coffeeify'
    .bundle()
    .pipe source 'index.js'
    .pipe gulp.dest 'www/js'
    .pipe streamify uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest 'www/js'
