if (require.extensions['.coffee']) {
  module.exports = require('./lib/repeat.coffee');
} else {
  module.exports = require('./out/release/lib/repeat.js');
}