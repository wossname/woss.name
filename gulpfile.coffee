path  = require 'path'
gulp  = require 'gulp'
bower = require 'gulp-bower'
less  = require 'gulp-less'

gulp.task 'default', [ 'build' ]

gulp.task 'install', ->
  bower()

gulp.task 'build', [ 'build:stylesheets' ], ->
  console.log 'Hello world.'

gulp.task 'build:stylesheets', ->
  gulp.src('source/stylesheets/**/*.less')
    .pipe(less(paths: [ path.join(__dirname, 'bower_components', 'bootstrap', 'less') ]))
    .pipe(gulp.dest('dist/stylesheets'))

gulp.task 'serve', [ 'build', 'watch' ]

gulp.task 'watch', ->
  gulp.watch 'gulpfile.coffee'
