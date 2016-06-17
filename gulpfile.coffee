gulp  = require 'gulp'
bower = require 'gulp-bower'

gulp.task 'default', [ 'build' ]

gulp.task 'install', ->
  bower()

gulp.task 'build', ->
  console.log 'Hello world.'

gulp.task 'serve', [ 'build', 'watch' ]

gulp.task 'watch', ->
  gulp.watch 'gulpfile.coffee'
