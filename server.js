const Path = require('path');

const Express = require('express');
const Configuration = require('configuration-wrapper');

const libPath = Path.join(__dirname, 'lib');
const cfgPath = Path.join(__dirname, 'cfg');
const cfgFile = Path.join(cfgPath, 'server.yml');

const Services = require(Path.join(libPath, 'services.js'));
const applyRoutes = require(Path.join(__dirname, 'routes.js'));


const configuration = Configuration.fromFile(cfgFile);

const publicPath = configuration.public;
const dbURL = configuration.database;
const pathPrefix = configuration.prefix;

const dbClient = new Services.Database.Client(dbURL);

const app = Express();

function callback(req, res) {
  let sanitized = req.path.match(/^[\/]+([\w\.\/-]+)$/);
  let nodes = sanitized && sanitized[1].split(/\//);

  nodes = nodes.filter((node) => node != pathPrefix);

  let table = nodes[0];
  let handle = nodes[1];
  let column = nodes[2];

  let query;

  let promise;
  let criteria = req.query;
  let updates = Object.assign(req.params, req.body);

  switch(req.method) {

    case 'POST':
      promise = dbClient.create(table, updates);
      break;

    case 'GET':
      if (criteria.handle) {
        // grab a specific entry, given a handle. this
        // bypasses any flags blocking mass retrieval.
        handle = criteria.handle;

        delete criteria.handle;
      }

      promise = dbClient.get(table, handle, column, criteria);
      break;

    case 'PATCH':
      promise = dbClient.update(table, handle, updates);
      break;

    case 'PUT':
      let update = {};

      update[column] = updates[column];
      promise = dbClient.update(table, handle, update);
      break;

  };

  promise.then((rows) => {

    res.status(200)
      .send(rows)
      .end();
  });

}

applyRoutes(app, callback, {
  prefix: pathPrefix,
});

app.use(Express.static(publicPath));  // public assets path.
app.use(Express.json());


app.listen(5000, () => {
  console.log('started');
});

process.on('exit', (code) => {
  dbClient.close();

  console.log('exited');
});

process.on('SIGINT', process.exit);
process.on('SIGTERM', process.exit);
