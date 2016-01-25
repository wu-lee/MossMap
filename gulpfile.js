// gulpfile.js 
var gulp = require('gulp')
var rimraf = require('gulp-rimraf')
//var livereload = require('gulp-livereload')
var path = require('path')
var gbundle = require('gulp-bundle-assets')

gulp.task('default', ['bundle']);

gulp.task('bundle', ['clean'], function () {
    return gulp.src('./bundle.config.js')
        .pipe(gbundle({
            //bundleAllEnvironments: true,
            //quietMode: true
        }))
        .pipe(gbundle.results({
            dest: './',
//            pathPrefix: '/couchapp/',
//            fileName: 'manifest'
        }))
        .pipe(gulp.dest('./couchapp'));
});



/*
gulp.task('watch', function () {
    livereload.listen();
    gulp.watch(['./public/*.*']).on('change', livereload);
    gbundle.watch({
        //bundleAllEnvironments: true,
        //quietMode: true,
        configPath: path.join(__dirname, 'bundle.config.js'),
        results: {
            dest: __dirname,
            pathPrefix: '/public/',
            fileName: 'manifest'
        },
        dest: path.join(__dirname, 'public')
    });
});
*/
gulp.task('clean', function () {
// FIXME disabled pending my decision how to build
    return gulp.src('./couchapp/mossmap/_design/_attachments/3rdparty*', { read: false })
        .pipe(rimraf());
});
