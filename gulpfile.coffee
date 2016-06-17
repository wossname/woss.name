path         = require 'path'
gulp         = require 'gulp'
bower        = require 'gulp-bower'
concat       = require 'gulp-concat'
less         = require 'gulp-less'
autoprefixer = require 'gulp-autoprefixer'
sourcemaps   = require 'gulp-sourcemaps'
minifyCSS    = require 'gulp-minify-css'
uglify       = require 'gulp-uglify'

paths =
  less: 'source/stylesheets/**/*.less'
  javascripts: [
    path.join(__dirname, 'bower_components', 'jquery', 'dist', 'jquery.js'),
    path.join(__dirname, 'bower_components', 'bootstrap', 'js', '*.js'),
    'source/javascripts/**/*.js'
  ]
  lessPaths: [ path.join(__dirname, 'bower_components', 'bootstrap', 'less') ]
  dist:
    stylesheets: path.join(__dirname, 'dist', 'stylesheets')
    javascripts: path.join(__dirname, 'dist', 'javascripts')

gulp.task 'default', [ 'build:production' ]

gulp.task 'install', ->
  bower()

[ 'development', 'production' ].map (environment) ->
  gulp.task "build:#{environment}", [ "build:stylesheets:#{environment}", "build:javascripts:#{environment}" ]

gulp.task 'build:stylesheets:development', ->
  gulp.src(paths.less)
    .pipe(sourcemaps.init())
    .pipe(less(paths: paths.lessPaths))
    .pipe(autoprefixer())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.dist.stylesheets))

gulp.task 'build:stylesheets:production', ->
  gulp.src(paths.less)
    .pipe(sourcemaps.init())
    .pipe(less(paths: paths.lessPaths))
    .pipe(minifyCSS())
    .pipe(autoprefixer())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.dist.stylesheets))

gulp.task 'build:javascripts:development', ->
  gulp.src(paths.javascripts)
    .pipe(sourcemaps.init())
    .pipe(concat('all.js'))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.dist.javascripts))

gulp.task 'build:javascripts:production', ->
  gulp.src(paths.javascripts)
    .pipe(sourcemaps.init())
    .pipe(concat('all.js'))
    .pipe(uglify())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.dist.javascripts))

gulp.task 'serve', [ 'build:development', 'watch' ]

gulp.task 'watch', ->
  watchedLessPaths = paths.lessPaths.map (lessPath) -> path.join(lessPath, '**', '*')
  gulp.watch [ paths.less ].concat(watchedLessPaths), [ 'build:stylesheets:development' ]
  gulp.watch paths.javascripts, [ 'build:javascripts:development' ]
