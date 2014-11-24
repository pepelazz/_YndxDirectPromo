gulp = require('gulp')
coffee = require('gulp-coffee')
compass = require('gulp-compass')
minifyCSSGulp = require('gulp-minify-css')
minifyHtml = require('gulp-minify-html')
concat = require('gulp-concat')
uglifyjs = require('gulp-uglifyjs')
header = require('gulp-header')
rename = require('gulp-rename')
gutil = require('gulp-util')
jade = require('gulp-jade')
gulpif = require('gulp-if')
tplCache  = require('gulp-angular-templatecache')
webserver  = require('gulp-webserver')
htmlreplace  = require('gulp-html-replace')
rimraf  = require('gulp-rimraf')
fileinclude = require('gulp-file-include')
gulpsync  = require('gulp-sync')(gulp)

paths =
  templates: '/templates'

gulp.task 'default', gulpsync.sync(['cleanup', 'build', 'webserver'])

gulp.task 'cleanup', [] , ->
  gulp.src('./build/*', read: false)
  .pipe(rimraf())

gulp.task 'build', ['index', 'appJS', 'testsJS', 'templates', 'sass', 'resources'] , ->
  gulp.watch ['./app/html/index.jade', './app/html/index.html'], ['index']
  gulp.watch ['!./app/scripts/**/*_test.js', './app/scripts/**/*.js', '!./app/scripts/**/*_test.coffee', './app/scripts/**/*.coffee'], ['appJS']
  gulp.watch ['./app/scripts/**/*_test.js', './app/scripts/**/*_test.coffee'], ['testsJS']
  gulp.watch ['!./app/html/index.jade', '!./app/html/index.html', './app/html/**/*.html', './app/html/**/*.jade'], ['templates', 'index']
  gulp.watch ['./app/style/**/*.sass', './app/style/**/*.scss'], ['sass']
  gulp.watch ['./app/images/**/*', './libs/**/*'], ['resources']

gulp.task 'index', ->
  gulp.src([
    './app/html/index.jade'
    './app/html/index.html'
  ])
  .pipe(gulpif(/[.]jade$/, jade(pretty: gutil.env.type == 'dev').on('error', gutil.log)))
  .pipe(htmlreplace(js:
    if gutil.env.type == 'dev' then ['app.js']
    else ['app.js']))
  .pipe(if gutil.env.type == 'dev' then gutil.noop() else minifyHtml(empty:true))
  .pipe gulp.dest('./build')
  return

# concatenate compiled .coffee files and js files into build/app.js
gulp.task 'appJS', ->
  gulp.src([
    '!./app/scripts/**/*_test.js'
    './app/scripts/**/*.js'
    '!./app/scripts/**/*_test.coffee'
    './app/scripts/**/*.coffee'
  ])
  .pipe(gulpif(/[.]coffee$/, coffee().on('error', gutil.log)))
  .pipe(if gutil.env.type == 'dev' then gutil.noop() else uglifyjs('app.js', outSourceMap: true))
  .pipe gulp.dest('./build')
  return

# compile tests written in coffee
gulp.task 'testsJS', ->
  gulp.src([
    './app/scripts/**/*_test.js'
    './app/scripts/**/*_test.coffee'
  ]).pipe(gulpif(/[.]coffee$/, coffee().on('error', gutil.log))).pipe gulp.dest('./test/js')
  return

# combine compiled Jade and html template files into build/template.js
gulp.task 'templates', ->
  gulp.src([
    '!./app/html/index.jade'
    '!./app/html/includes/*'
    './app/html/**/*.html'
    './app/html/**/*.jade'
  ])
  .pipe(gulpif(/[.]jade$/, jade(pretty: gutil.env.type == 'dev').on('error', gutil.log)))
  .pipe(if gutil.env.type == 'dev' then gutil.noop() else minifyHtml(empty:true))
#  .pipe(tplCache('templates.js', standalone: true))
  .pipe gulp.dest('./build')
  return

gulp.task 'sass', ->
  gulp.src(['./app/style/*.sass', './app/style/*.scss'])
  .pipe(compass(
      sass: './app/style'
      css: './build'
      require: ['susy', 'breakpoint', 'modular-scale']
    ))
  .pipe(if gutil.env.type == 'dev' then gutil.noop() else minifyCSSGulp())
  .pipe(gulp.dest('./build'))

gulp.task 'resources', ->
  gulp.src(['./app/images/**/*']).pipe(gulp.dest('./build/images'));
  gulp.src(['./app/data/**/*']).pipe(gulp.dest('./build/data'));
  gulp.src(['./libs/zepto-1.1.3/zepto.min.js']).pipe(gulp.dest('./build/libs'));
  gulp.src(['./libs/normalize/normalize.css']).pipe(gulp.dest('./build/libs'));

gulp.task 'webserver', ->
  gulp.src('build')
  .pipe(webserver(
      port: 80
      fallback: 'index.html'
    ))
