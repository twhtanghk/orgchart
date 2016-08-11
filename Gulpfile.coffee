argv = require('yargs').argv
gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
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

gulp.task 'copy', ->
  gulp.src(if argv.prod then './www/js/config/production.coffee' else './www/js/config/development.coffee')
    .pipe(rename('env.coffee'))
    .pipe(gulp.dest('./www/js/'))

    
gulp.task 'coffee', ['copy'], ->
  browserify(entries: ['./www/js/index.coffee'])
    .transform('coffeeify')
    .transform('debowerify')
    .bundle()
    .pipe(source('index.js'))
    .pipe(gulp.dest('./www/js/'))

gulp.task 'watch', ->
  gulp.watch(paths.sass, ['sass'])

gulp.task 'install', ['git-check'], ->
  bower.commands.install().on 'log', (data) ->
    gutil.log('bower', gutil.colors.cyan(data.id), data.message)
    
gulp.task 'git-check', (done) ->
  if (!sh.which('git'))
    console.log(
      '  ' + gutil.colors.red('Git is not installed.'),
      '\n  Git, the version control system, is required to download Ionic.',
      '\n  Download git here:', gutil.colors.cyan('http://git-scm.com/downloads') + '.',
      '\n  Once git is installed, run \'' + gutil.colors.cyan('gulp install') + '\' again.'
    )
    process.exit(1)
  done()

    
    