module.exports = {
    db: {
        url: "http://localhost:5984/mossmap/",
        ddocs: {
            monads: {
                css: [
                    'node_modules/bootstrap/dist/css/bootstrap.css'
                ],
                js: [
                    'node_modules/angular/angular.js',
                    'node_modules/angular-ui-bootstrap/dist/ui-bootstrap.js',
                    'node_modules/d3/d3.js',
                ],
                html: [
                ],
                dest: {
                    css: 'styles.css',
                    html: '.',
                    js: 'app.js',
                },
            },
        },
    }
};

