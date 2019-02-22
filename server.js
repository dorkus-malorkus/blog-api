const Path = require('path');

const Express = require('express');


const libPath = Path.join(__dirname, 'lib');
const Services = require(Path.join(libPath, 'services.js'));

const app = Express();


const publicPath = Path.join(process.cwd(), 'public');
const dbURL = 'postgresql://dm-api@localhost:5432/dm-api'
const pathPrefix = 'api'

app.use(Express.static(publicPath));  // public assets path.
app.use(Express.json());

const dbClient = new Services.Database.Client(dbURL);



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



let prefix;

//app.get('/*', callback);
prefix = [undefined, pathPrefix, 'authors'].join('/');

app.get(prefix + '/', callback);
app.get(prefix + '/:handle', callback);
app.get(prefix + '/:handle/handle', callback);
app.get(prefix + '/:handle/email', callback);
app.get(prefix + '/:handle/active', callback);
app.get(prefix + '/:handle/searchable', callback);
app.get(prefix + '/:handle/commenting', callback);
app.get(prefix + '/:handle/created', callback);
app.get(prefix + '/:handle/updated', callback);

app.post(prefix + '', callback);
app.patch(prefix + '/:handle', callback);

//app.put(prefix + '/:handle/handle', callback);
app.put(prefix + '/:handle/email', callback);
app.put(prefix + '/:handle/password', callback);
app.put(prefix + '/:handle/active', callback);
app.put(prefix + '/:handle/searchable', callback);
app.put(prefix + '/:handle/commenting', callback);
//app.put(prefix + '/:handle/created', callback);
//app.put(prefix + '/:handle/updated', callback);
//app.delete(prefix + '/:handle', callback.bind(undefined, service));


prefix = [undefined, pathPrefix, 'posts'].join('/');

app.get(prefix + '/', callback);
app.get(prefix + '/:handle', callback);
app.get(prefix + '/:handle/handle', callback);
app.get(prefix + '/:handle/author', callback);
app.get(prefix + '/:handle/parent', callback);
app.get(prefix + '/:handle/header', callback);
app.get(prefix + '/:handle/body', callback);
app.get(prefix + '/:handle/subheader', callback);
app.get(prefix + '/:handle/active', callback);
app.get(prefix + '/:handle/searchable', callback);
app.get(prefix + '/:handle/commenting', callback);
app.get(prefix + '/:handle/expanded', callback);
app.get(prefix + '/:handle/topic', callback);
app.get(prefix + '/:handle/created', callback);
app.get(prefix + '/:handle/updated', callback);

app.post(prefix + '', callback);
app.patch(prefix + '/:handle', callback);

//app.put(prefix + '/:handle/handle', callback);
app.put(prefix + '/:handle/author', callback);
app.put(prefix + '/:handle/parent', callback);
app.put(prefix + '/:handle/header', callback);
app.put(prefix + '/:handle/body', callback);
app.put(prefix + '/:handle/subheader', callback);
app.put(prefix + '/:handle/active', callback);
app.put(prefix + '/:handle/searchable', callback);
app.put(prefix + '/:handle/commenting', callback);
app.put(prefix + '/:handle/expanded', callback);
//app.put(prefix + '/:handle/created', callback);
//app.put(prefix + '/:handle/updated', callback);
//app.delete(prefix + '/:handle',


prefix = [undefined, pathPrefix, 'topics'].join('/');

app.get(prefix + '/', callback);
app.get(prefix + '/:handle', callback);
app.get(prefix + '/:handle/handle', callback);


app.listen(5000, () => {
  console.log('started');
});

process.on('exit', (code) => {
  dbClient.close();

  console.log('exited');
});

process.on('SIGINT', process.exit);
process.on('SIGINT', process.exit);
