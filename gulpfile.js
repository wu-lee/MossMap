'use strict';

var gulp = require('gulp');
var gutil = require('gulp-util');
var push = require('couchdb-gulp');
var minimist = require('minimist');

var options = minimist(
    process.argv.slice(2),
    {
        string: 'url',
        'default': {
            url: 'mossmap',
        },
    });

var config;
var couch_url = options['url'];
try {
    config = require('./config.json');
    couch_url = config.db;
} catch(e) {}
gutil.log("url is "+couch_url); // DEBUG

if (!couch_url) {
    gutil.log('You must supply the URL to your CouchDB instance (via the --url option or config.json');
    process.exit(1);
}


// FIME hacky
gulp.task('_design/import', function() {
    gulp.src('node_modules/papaparse/papaparse.js')
        .pipe(gulp.dest('_design/import/_attachments/js'));
    gulp.src('node_modules/bootstrap/dist/css/bootstrap.css')
        .pipe(gulp.dest('_design/import/_attachments/css'));
});

gulp.task('docs', function() {
    gulp.src('_docs/*')
        .pipe(push(couch_url))
});


gulp.task('apps', function() {
    gulp.src('_design/*')
        .pipe(push(couch_url))
});

gulp.task('watch', ['default'], function() {
    gulp.watch('./_design/**/*', 
               ['apps'])
//        .on('change', function(x) { console.log(">>>", x) })
    gulp.watch('./_docs/*', ['docs']);
});

gulp.task('default', ['_design/import', 'apps', 'docs'], function() {
});
