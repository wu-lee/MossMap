var config;
try {
    config = require('./local-config.js');
}
catch(e) {
    config = require('./default-config.js');
}

// For convenience
config.url.db = config.url.server + config.url.dbName;
module.exports = config;
