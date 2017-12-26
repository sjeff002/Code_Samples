var express = require('express');
var bodyParser = require('body-parser');
var mysql = require('./dbcon.js');
var app = express();
var handlebars = require('express-handlebars').create({defaultLayout:'main'});

app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');
app.set('port', 4252);
app.use(bodyParser.urlencoded({extended:false}));
app.use(express.static('public'));


app.get('/', function(req, res, next){
	var myContent = {};

	mysql.pool.query('SELECT * FROM workouts', function(err, rows, fields){
		if(err){
			next(err);
			return;
		}

		myContent.results = rows;
		res.render('home', myContent);
	});
});

app.get('/reset-table',function(req,res,next){
  var context = {};
  mysql.pool.query("DROP TABLE IF EXISTS workouts", function(err){ //replace your connection pool with the your variable containing the connection pool
    var createString = "CREATE TABLE workouts("+
    "id INT PRIMARY KEY AUTO_INCREMENT,"+
    "name VARCHAR(255) NOT NULL,"+
    "reps INT,"+
    "weight INT,"+
    "date DATE,"+
    "lbs BOOLEAN)";
    mysql.pool.query(createString, function(err){
      context.results = "Table reset";
      res.render('home',context);
    })
  });
});

app.get('/insert', function(req, res, next){
	var myContent = {};

	mysql.pool.query("INSERT INTO workouts (`name`, `reps`, `weight`,`date`,`lbs`) VALUES (?, ?, ?, ?, ?)", [req.query.name,req.query.reps,req.query.weight,req.query.date,req.query.lbs], function(err, result){
		if(err){
			next(err);
			return;
		}
		
		myContent.inserted = result.insertId;
		res.send(JSON.stringify(myContent));
	});
});

app.get('/delete', function(req, res, next){
	var myContent = {};

	mysql.pool.query("DELETE FROM workouts WHERE id = ?", [req.query.id], function(err, result){
		if(err){
			next(err);
			return;
		}
	});
});

app.get('/update', function(req, res, next){
	var myContent = {};

	mysql.pool.query('SELECT * FROM workouts WHERE id=?', [req.query.id], function(err, rows, fields){
		if(err){
			next(err);
			return;
		}

		myContent.results = rows[0];
		res.render('update', myContent);
	});
});

app.get('/updateForm', function(req, res, next){
	var myContent = {};

	mysql.pool.query("SELECT * FROM workouts WHERE id=?", [req.query.id], function(err, result){
		if(err){
			next(err);
			return;
		}

		if(result.length == 1){
			var curVals = result[0];
			mysql.pool.query("UPDATE workouts SET name=?, reps=?, weight=?, date=?, lbs=? WHERE id = ?",
				[req.query.name || curVals.name, req.query.reps || curVals.reps, req.query.weight || curVals.weight, req.query.date || curVals.date, req.query.lbs || curVals.lbs, req.query.id], function(err, results){
					if(err){
						next(err);
						return;
					}

					mysql.pool.query('SELECT * FROM workouts', function(err, rows, fields){
						if(err){
						next(err);
						return;
						}

						myContent.results = rows;
						res.render('home', myContent);
					});
			});
		}
	});
});

app.use(function(req, res){
	res.status(404);
	res.render('404');
});

app.use(function(err, req, res, next){
	console.error(err.stack);
	res.type('plain/text');
	res.status(500);
	res.render('500');
});

app.listen(app.get('port'), function(){
	console.log('Express has started on port ' + app.get('port'));
});

