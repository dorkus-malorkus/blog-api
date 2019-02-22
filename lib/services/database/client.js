

const PGPool = require('pg').Pool;


class DatabaseClient {

  constructor(dbURL) {

    this.pool = new PGPool({
      connectionString: dbURL,
    });

    this.pool.connect();
  }

  query(str, vals) {
    let promise = new Promise(((resolve, reject) => {

      this.pool.query(str, vals, (err, res) => {

        if (!err) {
          resolve(res.rows);

        } else {
          reject(err);

        }

      });

    }).bind(this));

    return promise;
  }

  close() {
    this.pool.end();
  }

  create(table, updates) {
    let columns = Object.keys(updates);
    let values = Object.values(updates);


    let query = [
      'INSERT INTO', table, ('(' + columns.join(', ') + ')'),
      'VALUES', '(' +
        columns.map((col, idx) => {
          return '$' + (idx + 1).toString();
        }).join(', ') +
      ')',
    ];

    return this.query(query.join(' '), values);
  }

  get(table, handle, columns, criteria) {
    let vals = [];
    let crit;
    let cols = 'handle'; // default to just the handles.

    if (columns) {
      cols = columns.constructor == Array ? columns.join(', ') : columns;
    }

    let query = [
      'SELECT', cols,
      'FROM', table,
      'WHERE active IS TRUE',
    ];

    if (criteria) {

      crit = Object.keys(criteria).map((targKey) => {
        let targObj = criteria[targKey];

        if (targObj.constructor == String && isNaN(targObj)
            && !['true', 'false'].includes(targObj.toLowerCase())) {
          // we have a string.

          vals.push("%" + targObj + "%");
          return [targKey, 'LIKE', ('$' + vals.length)].join(' ');

        } else if (['true', 'false'].includes(targObj.toLowerCase())) {
          // we have a boolean.

          vals.push(targObj.toLowerCase() == 'true' ? true : false);
          return [targKey, '=', ('$' + vals.length)].join(' ');

        } else {
          // we have a number.

          vals.push(Number(targObj));
          return [targKey, '=', ('$' + vals.length)].join(' ');

        }

      });

    }

    if (handle) {
      vals.push(handle);
      query.push('AND LOWER(handle) = LOWER($' + vals.length + ')');

    } else {
      query.push('AND searchable IS TRUE');

    }

    if (crit && crit.length > 0) {
      let clause = crit.join(' AND ');

      query.push('AND ' + clause);
    }

    return this.query(query.join(' '), vals);
  }

  update(table, handle, updates, criteria) {
    let vals = [handle];
    let crit;

    let sets = Object.keys(updates).map(((updates, targKey) => {
      let targObj = updates[targKey];

      vals.push(targObj);

      return [targKey, '=', ('$' + vals.length)].join(' ');

    }).bind(undefined, updates));

    let query = [
      'UPDATE', table,
      'SET', sets.join(', '),
      'WHERE active IS TRUE',
        'AND LOWER(handle) = LOWER($1)',
    ];

    if (criteria) {

      crit = Object.keys(criteria).map((targKey) => {
        let targObj = criteria[targKey];

        if (targObj.constructor == String && isNaN(targObj)
            && !['true', 'false'].includes(targObj.toLowerCase())) {
          // we have a string.

          vals.push("%" + targObj + "%");
          return [targKey, 'LIKE', ('$' + vals.length)].join(' ');

        } else if (['true', 'false'].includes(targObj.toLowerCase())) {
          // we have a boolean.

          vals.push(targObj.toLowerCase() == 'true' ? true : false);
          return [targKey, '=', ('$' + vals.length)].join(' ');

        } else {
          // we have a number.

          vals.push(Number(targObj));
          return [targKey, '=', ('$' + vals.length)].join(' ');

        }

      });

    }

    if (crit && crit.length > 0) {
      let clause = crit.join(' AND ');

      query.push('AND ' + clause);
    }

    return this.query(query.join(' '), vals);
  }


}


module.exports = DatabaseClient;
