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
    [
      'transition', 'alert', 'affix', 'button', 'carousel', 'collapse',
      'dropdown', 'modal', 'tooltip', 'popover', 'scrollspy', 'tab'
    ].map (component) ->
      path.join(__dirname, 'node_modules', 'toolkit-dashboard', 'js', 'bootstrap', "#{component}.js")
    path.join(__dirname, 'node_modules', 'toolkit-dashboard', 'js', 'custom', '*.js')
    'source/javascripts/**/*.js'
  ].reduce(((a, i) -> a.concat(i)), [])
  fonts: [
    path.join(__dirname, 'node_modules', 'toolkit-dashboard', 'fonts', '*')
  ]
  lessPaths: [ path.join(__dirname, 'node_modules', 'toolkit-dashboard', 'less') ]
  dist:
    stylesheets: path.join(__dirname, 'dist', 'stylesheets')
    javascripts: path.join(__dirname, 'dist', 'javascripts')
    fonts:       path.join(__dirname, 'dist', 'fonts')

gulp.task 'default', [ 'build:production' ]

gulp.task 'install', ->
  bower()

[ 'development', 'production' ].map (environment) ->
  gulp.task "build:#{environment}", [ "build:stylesheets:#{environment}", "build:javascripts:#{environment}", "build:fonts" ]

gulp.task 'build:stylesheets:development', ->
  gulp.src(paths.less)
    .pipe(sourcemaps.init(loadMaps: true))
    .pipe(less(paths: paths.lessPaths))
    .pipe(autoprefixer())
    .pipe(sourcemaps.write('../maps'))
    .pipe(gulp.dest(paths.dist.stylesheets))

gulp.task 'build:stylesheets:production', ->
  gulp.src(paths.less)
    .pipe(sourcemaps.init(loadMaps: true))
    .pipe(less(paths: paths.lessPaths))
    .pipe(minifyCSS())
    .pipe(autoprefixer())
    .pipe(sourcemaps.write('../maps'))
    .pipe(gulp.dest(paths.dist.stylesheets))

gulp.task 'build:javascripts:development', ->
  gulp.src(paths.javascripts)
    .pipe(sourcemaps.init(loadMaps: true))
    .pipe(concat('all.js'))
    .pipe(sourcemaps.write('../maps'))
    .pipe(gulp.dest(paths.dist.javascripts))

gulp.task 'build:javascripts:production', ->
  gulp.src(paths.javascripts)
    .pipe(sourcemaps.init(loadMaps: true))
    .pipe(concat('all.js'))
    .pipe(uglify())
    .pipe(sourcemaps.write('../maps'))
    .pipe(gulp.dest(paths.dist.javascripts))

gulp.task 'build:fonts', ->
  gulp.src(paths.fonts)
    .pipe(gulp.dest(paths.dist.fonts))

gulp.task 'serve', [ 'build:development', 'watch' ]

gulp.task 'watch', ->
  watchedLessPaths = paths.lessPaths.map (lessPath) -> path.join(lessPath, '**', '*')
  gulp.watch [ paths.less ].concat(watchedLessPaths), [ 'build:stylesheets:development' ]
  gulp.watch paths.javascripts, [ 'build:javascripts:development' ]
  gulp.watch paths.fonts, [ 'build:fonts' ]
