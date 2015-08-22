var db_config = require('./config.js');
var express = require('express');
var app = express();
var massive = require("massive");
var bodyParser = require('body-parser');

/* Connect to postgres */
var connectionString = "postgres://" + db_config.user +":"+ db_config.password +"@"+ db_config.host +"/"+ db_config.database
console.log(connectionString);
var massiveInstance = massive.connectSync({connectionString: connectionString});


/* Set up global db reference */
app.set('db', massiveInstance);
app.use(function(req, res, next){
		req.db = massiveInstance
		next();
});


var jsonParser = bodyParser.json();

/* Pull in the auth code */
var auth = require('./auth.js')(app);

app.use('/', express.static('static'));
app.get('/api', function (req, res) {
  res.send('Say Hi, World!');
});

app.get('/api/profile/:id', function(req, res){
  var id = req.params.id;
  req.db.profile.Profile.find({ProfileId: id}, function(err, n){
	res.json(n);
  });
});

app.get('/api/bizcard/:id', function(req, res){
  var id = req.params.id;
  req.db.profile.BusinessCards.find({ProfileId: id}, function(err, n){
	res.json(n);
  });
});

app.get('/api/AverageRatings/:User/:RatingWho', function(req, res){
  var user = req.params.User;
  var ratingwho = req.params.RatingWho;
  req.db.AverageRatings([user, ratingwho], function(err, n){
	console.log(err);
	res.json(n);
  });
});

/* Take in GeoJson, then:
*  - Make an insertion into the LoggedLocations table (once auth is working)
*  - Do a search on the Nearme table, and return the results
*/
app.post('/api/Location', jsonParser, function(req, res){
  /* Take in  { "lat": number, "lon": number, "accuracy": number} */
  /* Where "accuracy" is the accuracy radius reported by the phone */
  var latitude = req.body.lat;
  var longitude = req.body.lon;
  var accuracy  = req.body.accuracy;
	/* Insert into logged locations later */
  req.db.Nearme([longitude, latitude], function(err, n){
	console.log(err);
	res.json(n);
  });
});


var server = app.listen(80, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});

