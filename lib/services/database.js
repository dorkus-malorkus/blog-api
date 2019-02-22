const Path = require('path');

const libPath = Path.join(__dirname, 'database');
const DatabaseClient = require(Path.join(libPath, 'client.js'));



class Database {

  static get Client() {
    return DatabaseClient;
  }

}


module.exports = Database;
