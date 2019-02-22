

module.exports = (app, callback, cfg) => {
  let pathPrefix = cfg.prefix;

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

};
