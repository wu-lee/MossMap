module.exports = function(grunt) {
    
    var _ = require('lodash');
    grunt.initConfig({
        flatValues: function(obj, key) {
            function transform(m,v,k) { 
                if (k === key)
                    m[v] = 1; 
                if (v instanceof Object)
                    _.transform(v, transform, m);
            }
            return Object.keys(_.transform(obj, transform));
        },
        jshint: {            
            nodejs: {
                src: ['Gruntfile.js'],
            },
            browser: {
                src: ['src/browser/**/*.js'],
                options: {
                    browser: true,
                    jquery: true,
                },
            },
        },
        copy: {
            js: {
                files: [
                    { 
                        src: 'node_modules/jquery/dist/jquery.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/jquery.js' 
                    },
                    { 
                        src: 'node_modules/angular/angular.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/angular.js' 
                    },
                    { 
                        src: 'node_modules/angular-animate/angular-animate.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/angular-animate.js' 
                    },
                    { 
                        src: 'node_modules/angular-ui-bootstrap/dist/ui-bootstrap-tpls.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/ui-bootstrap.js' 
                    },
                    { 
                        src: 'bower_components/CornerCouch/angular-cornercouch.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/angular-cornercouch.js' 
                    },
                    {
                        src: 'node_modules/d3/d3.js',
                        dest: 'couchdb/mossmap/_attachments/3p/d3.js' 
                    },
                    {
                        src: 'node_modules/dinty/dinty.js',
                        dest: 'couchdb/mossmap/_attachments/3p/dinty.js' 
                    },
                    {
                        expand: true,
                        cwd: 'src/browser/',
                        src: '*.js',
                        dest: 'couchdb/mossmap/_attachments/js/',
                    }
                ],
            },
            css: {
                files: [
                    { 
                        src: 'node_modules/bootstrap/dist/css/bootstrap.css', 
                        dest: 'couchdb/mossmap/_attachments/3p/bootstrap.css' 
                    },
                ],
            },
            fonts: {
                files: [
                    { 
                        src: 'node_modules/bootstrap/dist/fonts/glyphicons-halflings-regular.woff2', 
                        dest: 'couchdb/mossmap/_attachments/fonts/glyphicons-halflings-regular.woff2' 
                    },
                ],
            },
            html: {
                files: [
                    {
                        src: 'src/mossmap/index.html',
                        dest: 'couchdb/mossmap/_attachments/index.html'
                    }
                ],
            },
        },
        'couch-compile': {
            mossmap: {
                files: {
                    'tmp/mossmap.json': 'couchdb/*'
                }
            }
        },
        'couch-push': {
            options: {
//                user: 'karin',
//                pass: 'secure'
            },
            localhost: {
                files: {
                    'http://localhost:5984/mossmap': ['tmp/mossmap.json' ],
                }
            }
        },
        watch: {
            jshint: {
                files: ['<%= jshint.files %>'],
                tasks: ['jshint']
            },
            grunt: {
                files: ['Gruntfile.js'],
            },
            push: {
                files: [
                    'Gruntfile.js',
                    "<%= flatValues(copy, 'src') %>",
                    'couchdb/*/**',
                ],
                tasks: ['push']
            }
        }
    });
    
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-couch');
    grunt.registerTask('push', ['copy', 'couch-compile', 'couch-push']);
    grunt.registerTask('default', ['jshint', 'push']);
};
