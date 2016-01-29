'use strict';

var through = require('through2');
var push = require('couchdb-push');
var gutil = require('gulp-util');
var PLUGIN_NAME = 'couchdb-push';

module.exports = function (couchdb_url, options) {

    return through.obj(function (file, enc, callback) {
        if (file === null) {
            return callback();
        }
        if (file.path.match(/~$/)) { // Ignored
            return callback();
        }
        var that = this;
        push(couchdb_url, file.path, function(err, response) {
            if (err) {
                that.emit('error', 
                          new gutil.PluginError(PLUGIN_NAME, err.error || err));
                return callback(err, response);
            }
            
            gutil.log("pushing "+file.path.replace(file.cwd, '.')+" -> "+couchdb_url);
            callback();
        });
    });
};
