path         = require 'path'
gulp         = require 'gulp'
bower        = require 'gulp-bower'
less         = require 'gulp-less'
autoprefixer = require 'gulp-autoprefixer'

paths =
  less: 'source/stylesheets/**/*.less'
  lessPaths: [ path.join(__dirname, 'bower_components', 'bootstrap', 'less') ]
  dist:
    stylesheets: path.join(__dirname, 'dist', 'stylesheets')

gulp.task 'default', [ 'build:production' ]

gulp.task 'install', ->
  bower()

[ 'development', 'production' ].map (environment) ->
  gulp.task "build:#{environment}", [ "build:stylesheets:#{environment}" ]

gulp.task 'build:stylesheets:development', ->
  gulp.src(paths.less)
    .pipe(less(paths: paths.lessPaths))
    .pipe(autoprefixer())
    .pipe(gulp.dest(paths.dist.stylesheets))

gulp.task 'build:stylesheets:production', ->
  gulp.src(paths.less)
    .pipe(less(paths: paths.lessPaths))
    .pipe(autoprefixer())
    .pipe(gulp.dest(paths.dist.stylesheets))

gulp.task 'serve', [ 'build:development', 'watch' ]

gulp.task 'watch', ->
  gulp.watch 'gulpfile.coffee'
