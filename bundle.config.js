// bundle.config.js 

var prodLikeEnvs = ['production'];
var commonOptions = {
    useMin: prodLikeEnvs, // {(boolean|string|Array)} pre-minified files from bower
    uglify: prodLikeEnvs, // {(boolean|string|Array)} js minification
    minCSS: prodLikeEnvs, // {(boolean|string|Array)} css minification
    rev: true // {(boolean|string|Array)} file revisioning
};
module.exports = {
    bundle: {
        'mossmap/_design/_attachments/3rdparty': {
            scripts: [
                'node_modules/angular/angular.js',
                'node_modules/angular-ui-bootstrap/dist/ui-bootstrap.js',
                'node_modules/d3/d3.js',
            ],
            styles: [
                'node_modules/bootstrap/dist/css/bootstrap.css',
            ],
            options: commonOptions,
        }
    },
    //copy: './content/**/*.{png,svg}'
};
