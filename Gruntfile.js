module.exports = function(grunt) {
    
    var _ = require('lodash');
    var config = require('./config.js');

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
            options: {
                nonbsp: true,
                unused: 'vars',
                undef: true,
            },
            nodejs: {
                options: {
                    node: true,
                },
                files: { src: ['Gruntfile.js'] },
            },
            browser: {
                src: ['src/browser/**/*.js'],
                options: {
                    browser: true,
                    jquery: true,
                    globals: {
                        angular: false,
                        d3: false,
                        require: false,
                    },
                },
            },
            couchdb: {
                src: ['src/mossmap/{shows,views,updates,lists,js}/**/*.js'],
                options: {
                    couch: true,
                    expr: true,
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
                        src: 'node_modules/angular-resource/angular-resource.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/angular-resource.js' 
                    },
                    { 
                        src: 'node_modules/angular-route/angular-route.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/angular-route.js' 
                    },
                    { 
                        src: 'node_modules/angular-ui-bootstrap/dist/ui-bootstrap-tpls.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/ui-bootstrap.js' 
                    },
                    { 
                        src: 'node_modules/CornerCouch/angular-cornercouch.js', 
                        dest: 'couchdb/mossmap/_attachments/3p/angular-cornercouch.js' 
                    },
                    {
                        src: 'node_modules/angular-ui-grid/ui-grid.js',
                        dest: 'couchdb/mossmap/_attachments/3p/ui-grid.js' 
                    },
                    {
                        src: 'node_modules/d3/d3.js',
                        dest: 'couchdb/mossmap/_attachments/3p/d3.js' 
                    },
                    {
                        src: 'node_modules/papaparse/papaparse.js',
                        dest: 'couchdb/mossmap/_attachments/3p/papaparse.js' 
                    },
                    {
                        src: 'node_modules/webshim/js-webshim/dev/polyfiller.js',
                        dest: 'couchdb/mossmap/_attachments/3p/polyfiller.js' 
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
                    {
                        src: 'node_modules/angular-ui-grid/ui-grid.css',
                        dest: 'couchdb/mossmap/_attachments/3p/ui-grid.css' 
                    },
                ],
            },
            fonts: {
                files: [
                    { 
                        src: 'node_modules/bootstrap/dist/fonts/glyphicons-halflings-regular.woff2', 
                        dest: 'couchdb/mossmap/_attachments/fonts/glyphicons-halflings-regular.woff2' 
                    },
                    { 
                        src: 'node_modules/angular-ui-grid/ui-grid.woff',
                        dest: 'couchdb/mossmap/_attachments/3p/ui-grid.woff' 
                    },
                ],
            },
            mossmap: {
                files: [
                    {
                        expand: true,
                        cwd: 'src/mossmap/',
                        src: ['**', '!**/*~'],
                        dest: 'couchdb/mossmap/'
                    }
                ],
            },
        },
        browserify: {
/*
            dinty: {
                src: 'dinty/dinty.js',
                dest: 'couchdb/mossmap/_attachments/3p/dinty.js',
                options: {
                    alias: ['dinty:'],
                },
            },*///FIXME need to ensure csv2json is requireable
            modules: {
                // modules which needs browserification
                src: './src/modules/mossmap-csv2json.js',
                dest: 'couchdb/mossmap/_attachments/js/mossmap.js',
                options: {
                    alias: ['dinty:'],
                },
            },
        },
        'couch-security': {
            localhost: {
                options: config.pushOptions,
                files: [
                    {
                        src: 'security.json',
                        dest: config.url.db,
                    },/*
                    { // Access to the data is variable
                        src: config.security,
                        dest: config.url.data,
                    },*/
                ],
            }
        },
        'couch-compile': {
            mossmap: {
                files: {
                    'tmp/mossmap.json': 'couchdb/*'
                }
            },
            set0: {
                files: {
                    'tmp/set0.json': 'example-data/cheshire-dataset-orig.json'
                },
            },
        },
        'couch-push': {
            options: config.pushOptions,
            localhost: {
                files: [
                    {
                        src: ['tmp/mossmap.json' ],
                        dest: config.url.db,
                    }
                ],
            },
            set0: {
                files: [
                    {
                        src: ['tmp/set0.json'],
                        dest: config.url.db,
                    },
                ]
            },
            bulk: {
                files: [
                    {
                        src: ['example-data/cheshire-dataset-bulk.json'],
                        dest: config.url.db,
                    },
                ],
            },
            records: {
                files: [
                    {
                        src: ['example-data/cheshire-dataset-records.json'],
                        dest: config.url.db,
                    },
                ],
            },
            completed: {
                files: [
                    {
                        src: ['example-data/cheshire-dataset-completed.json'],
                        dest: config.url.db,
                    },
                ],
            },
        },
        watch: {
            jshint: {
                files: ["<%= flatValues(jshint, 'src') %>"],
                tasks: ['jshint']
            },
            grunt: {
                files: [
                    'Gruntfile.js', 'default-config.js', 'local-config.js',
                    config.security,
                ],
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
    grunt.loadNpmTasks('grunt-browserify');
    grunt.registerTask('push', ['copy', 'browserify', 'couch-compile', 'couch-push:localhost']);
    grunt.registerTask('default', ['jshint', 'push']);
//    console.log(grunt.config.get('flatValues')(grunt.config.get('jshint'), 'src'));
//    console.log(JSON.stringify(grunt.config.get('copy'), null, 2));
//    process.exit(0);
};
