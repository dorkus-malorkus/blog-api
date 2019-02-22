
const Path = require('path');

const libPath = Path.join(__dirname, 'services');
const DatabaseService = require(Path.join(libPath, 'database.js'));


class Services {

  static get Database() {
    return DatabaseService;
  }

}


module.exports = Services;
