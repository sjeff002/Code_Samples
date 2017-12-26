var mysql = require('mysql');
var pool = mysql.createPool({
  connectionLimit : 10,
  host            : 'classmysql.engr.oregonstate.edu',
  user            : 'cs290_jeffesha',
  password        : '1Bianco!',
  database        : 'cs290_jeffesha'
});

module.exports.pool = pool;
