





module.exports = {




  getAuthorsByHandle: [
    'SELECT *',
    'FROM authors',
    'WHERE active IS TRUE',
      'AND handle = $1',
  ].join(' '),

  getAuthorsByEmail: [
    'SELECT *',
    'FROM authors',
    'WHERE active IS TRUE',
      'AND email = $1',
  ].join(' '),





};


module.exports = DatabaseQueries;
