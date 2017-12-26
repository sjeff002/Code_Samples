var express = require('express');

var app = express();
var handlebars = require('express-handlebars').create({defaultLayout:'main'});
var bodyParser = require('body-parser');
app.use(express.static('public'));
var mysql = require('./dbcon.js');


app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');
app.set('port', 4252);

// base page
app.get('/', function(req, res, next){
    var myContext = {};
    // select everything from workout table
    mysql.pool.query('SELECT * FROM workouts', function(err, rows, fields){
    if(err){
        next(err);
        return;
    }
    var myRows = [];
   
    for(var row in rows){
        var toPush = {'name': rows[row].name, 
                    'reps': rows[row].reps, 
                    'weight': rows[row].weight, 
                    'date':rows[row].date,
                    'lbs':rows[row].lbs, 
                    'id':rows[row].id};
        myRows.push(toPush);
    }

    myContext.results = myRows;
    res.render('home', myContext);
    });
});

// reset the table
app.get('/reset-table',function(req,res,next){
    var context = {};
    mysql.pool.query("DROP TABLE IF EXISTS workouts", function(err){
        var createString = "CREATE TABLE workouts("+
        "id INT PRIMARY KEY AUTO_INCREMENT,"+
        "name VARCHAR(255) NOT NULL,"+
        "reps INT,"+
        "weight INT,"+
        "date DATE,"+
        "lbs BOOLEAN)";
        mysql.pool.query(createString, function(err){
            res.render('home',context);
        })
    });
});

// handles inserting into table
app.get('/insert',function(req,res,next){
  var myContext = {};

  mysql.pool.query("INSERT INTO `workouts` (`name`, `reps`, `weight`, `date`, `lbs`) VALUES (?, ?, ?, ?, ?)", 
    [req.query.name, 
    req.query.reps, 
    req.query.weight, 
    req.query.date, 
    req.query.lbs], 
    function(err, result){
        if(err){
          next(err);
          return;
        } 
        myContext.inserted = result.insertId;
        res.send(JSON.stringify(myContext));
  });
});

// delete from table
app.get('/delete', function(req, res, next) {
    //var myContext = {};

    mysql.pool.query("DELETE FROM `workouts` WHERE id = ?", 
        [req.query.id], 
        function(err, result) {
            if(err){
                next(err);
                return;
            }
    });
});

// loads the update page
app.get('/update',function(req, res, next){
    var myContext = {};

    mysql.pool.query('SELECT * FROM `workouts` WHERE id=?',
        [req.query.id], 
        function(err, rows, fields){
            if(err){
                next(err);
                return;
            }
            var myRows = [];

            for(var row in rows){
                var toPush = {'name': rows[row].name, 
                            'reps': rows[row].reps, 
                            'weight': rows[row].weight, 
                            'date':rows[row].date, 
                            'lbs':rows[row].lbs,
                            'id':rows[row].id};

                myRows.push(toPush);
            }
        // only need the object being edited.
        myContext.results = myRows[0];
        res.render('update', myContext);
    });
});

// the handler for when the user is finished updating the entry
app.get('/updateForm', function(req, res, next){
    var myContext = {};
    //selecting by id so that we only get the row we want
    mysql.pool.query("SELECT * FROM `workouts` WHERE id=?", 
        [req.query.id], 
        function(err, result){
            if(err){
                next(err);
                return;
            }
            if(result.length == 1){
                // get the current values from the database
                var curVals = result[0];

                mysql.pool.query('UPDATE `workouts` SET name=?, reps=?, weight=?, date=?, lbs=? WHERE id=?', 
                [req.query.name || curVals.name, 
                req.query.reps || curVals.reps, 
                req.query.weight || curVals.weight, 
                req.query.date || curVals.date, 
                req.query.lbs || curVals.lbs, 
                req.query.id],
                function(err, result){
                    if(err){
                        next(err);
                        return;
                    }

                    // select everything so it can rerender
                    mysql.pool.query('SELECT * FROM `workouts`', function(err, rows, fields){
                        if(err){
                            next(err);
                            return;
                        }
                        var myRows = [];

                        for(var row in rows){
                            var toPush = {'name': rows[row].name, 
                            'reps': rows[row].reps,
                            'weight': rows[row].weight, 
                            'date':rows[row].date,
                            'lbs':rows[row].lbs,
                            'id':rows[row].id};

                            myRows.push(toPush);
                        }

                        myContext.results = myRows;
                        res.render('home', myContext);
                    });
                });
            }
    });
});

app.use(function(req,res){
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
    console.log('Express started on port: ' + app.get('port') + '; press Ctrl-C to terminate.');
});