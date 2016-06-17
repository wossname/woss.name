gulp = require 'gulp'

gulp.task 'default', [ 'build' ]

gulp.task 'build', ->
  console.log 'Hello world.'

gulp.task 'serve', [ 'build', 'watch' ]

gulp.task 'watch', ->
  gulp.watch 'gulpfile.coffee'
