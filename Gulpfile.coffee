gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
sass = require 'gulp-sass'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'

paths = sass: ['./scss/**/*.scss']

gulp.task 'default', ['sass', 'coffee']

gulp.task 'sass', (done) ->
  gulp.src('./scss/ionic.app.scss')
    .pipe(sass())
    .pipe(gulp.dest('./www/css/'))
    .pipe(minifyCss({
      keepSpecialComments: 0
    }))
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest('./www/css/'))

gulp.task 'coffee', ->
  browserify entries: ['./www/js/index.coffee']
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe source 'index.js'
    .pipe gulp.dest 'www/js'
