const Path = require('path');

const Express = require('express');


const libPath = Path.join(__dirname, 'lib');
const Services = require(Path.join(libPath, 'services.js'));

const app = Express();


const publicPath = Path.join(process.cwd(), 'public');
const dbURL = 'postgresql://dm-api@localhost:5432/dm-api'

app.use(Express.static(publicPath));  // public assets path.
app.use(Express.json());

const dbClient = new Services.Database.Client(dbURL);



function callback(req, res) {
  let sanitized = req.path.match(/^[\/]+([\w\.\/-]+)$/);
  let nodes = sanitized && sanitized[1].split(/\//);

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





//app.get('/*', callback);

app.get('/authors', callback);
app.get('/authors/:handle', callback);
app.get('/authors/:handle/handle', callback);
app.get('/authors/:handle/email', callback);
app.get('/authors/:handle/active', callback);
app.get('/authors/:handle/searchable', callback);
app.get('/authors/:handle/commenting', callback);
app.get('/authors/:handle/created', callback);
app.get('/authors/:handle/updated', callback);

app.post('/authors', callback);
app.patch('/authors/:handle', callback);

//app.put('/authors/:handle/handle', callback);
app.put('/authors/:handle/email', callback);
app.put('/authors/:handle/password', callback);
app.put('/authors/:handle/active', callback);
app.put('/authors/:handle/searchable', callback);
app.put('/authors/:handle/commenting', callback);
//app.put('/authors/:handle/created', callback);
//app.put('/authors/:handle/updated', callback);
//app.delete('/authors/:handle', callback.bind(undefined, service));


app.get('/posts', callback);
app.get('/posts/:handle', callback);
app.get('/posts/:handle/handle', callback);
app.get('/posts/:handle/author', callback);
app.get('/posts/:handle/parent', callback);
app.get('/posts/:handle/header', callback);
app.get('/posts/:handle/body', callback);
app.get('/posts/:handle/subheader', callback);
app.get('/posts/:handle/active', callback);
app.get('/posts/:handle/searchable', callback);
app.get('/posts/:handle/commenting', callback);
app.get('/posts/:handle/expanded', callback);
app.get('/posts/:handle/topic', callback);
app.get('/posts/:handle/created', callback);
app.get('/posts/:handle/updated', callback);

app.post('/posts', callback);
app.patch('/posts/:handle', callback);

//app.put('/posts/:handle/handle', callback);
app.put('/posts/:handle/author', callback);
app.put('/posts/:handle/parent', callback);
app.put('/posts/:handle/header', callback);
app.put('/posts/:handle/body', callback);
app.put('/posts/:handle/subheader', callback);
app.put('/posts/:handle/active', callback);
app.put('/posts/:handle/searchable', callback);
app.put('/posts/:handle/commenting', callback);
app.put('/posts/:handle/expanded', callback);
//app.put('/posts/:handle/created', callback);
//app.put('/posts/:handle/updated', callback);
//app.delete('/posts/:handle',

app.get('/topics', callback);
app.get('/topics/:handle', callback);
app.get('/topics/:handle/handle', callback);


app.listen(5000, () => {
  console.log('started');
});

process.on('exit', (code) => {
  dbClient.close();

  console.log('exited');
});

process.on('SIGINT', process.exit);
process.on('SIGINT', process.exit);
