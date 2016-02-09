'use strict';

var gulp = require('gulp');
var gutil = require('gulp-util');
var concat = require('gulp-concat');
var push = require('couchdb-gulp');
var minimist = require('minimist');
var path = require('path');
var rimraf = require('gulp-rimraf');

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
    config = require('./config.js');
    couch_url = config.db.url;
} catch(e) {}
gutil.log("url is "+couch_url); // DEBUG

if (!couch_url) {
    gutil.log('You must supply the URL to your CouchDB instance (via the --url option or config.js');
    process.exit(1);
}


var couchappDir = 'couchapp/mossmap';
var ddocs = config.db.ddocs;
gulp.task('css', function() {
    
    for(var ddocName in ddocs) {
        var ddoc = ddocs[ddocName]
        var dest = path.resolve(
            couchappDir,
            '_design',
            ddocName,
            '_attachments'
        );
        gulp.src(ddoc.css)
            .pipe(concat(ddoc.dest.css))
            .pipe(gulp.dest(dest))
    }
});

gulp.task('js', function() {
    for(var ddocName in ddocs) {
        var ddoc = ddocs[ddocName]
        var dest = path.resolve(
            couchappDir,
            '_design',
            ddocName,
            '_attachments'
        );
        gulp.src(ddoc.js)
            .pipe(concat(ddoc.dest.js))
            .pipe(gulp.dest(dest))
    }
});

gulp.task('html', function() {
    for(var ddocName in ddocs) {
        var ddoc = ddocs[ddocName]
        var dest = path.resolve(
            couchappDir,
            '_design',
            ddocName,
            '_attachments',
            ddoc.dest.html
        );
        gulp.src(ddoc.html)
        
            .pipe(gulp.dest(dest))
    }
});

gulp.task('couchdbjs', function() {
    for(var ddocName in ddocs) {
        var ddoc = ddocs[ddocName]

        var dest = path.resolve(
            couchappDir,
            '_design',
            ddocName
        );
        var src = path.resolve(
            'src',
            ddocName
        );
            
        gulp.src(src+'/*/*/*.js')
            .pipe(gulp.dest(dest))
    }
});

gulp.task('docs', function() {
    gulp.src('_docs/*')
        .pipe(push(couch_url))
});



gulp.task('pushDDocs', function() {
    var src = path.resolve(
        couchappDir,
        '_design'
    );
    gulp.src(src+'/*')
        .pipe(push(couch_url))
});

gulp.task('apps', ['css', 'js', 'html', 'couchdbjs', 'pushDDocs']);

gulp.task('watch', ['default'], function() {
    for(var ddocName in ddocs) {
        var ddoc = ddocs[ddocName];
        for(var type in ddoc.dest) {
            console.log("watch",type,ddoc[type])
            gulp.watch(ddoc[type], [type, 'pushDDocs']);
        }
    }
});

gulp.task('clean', function () {
    return gulp.src('couchapp/', { read: false })
        .pipe(rimraf());
});

gulp.task('default', ['apps', 'docs'], function() {
});

