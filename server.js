var db_config = require('./config.js');
express = require('express');
var flash = require('connect-flash');

_ = require('underscore');

passport = require('passport');

app = express();

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

/* Set up global logging middleware */
app.use(require('morgan')('dev'));


/* Global body parser */
var jsonParser = bodyParser.json();


/* Configure Express.Js in one shot */

var expressSession = require('express-session');

/* Set up Express for passport sessions */
app.use(require('cookie-parser')());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(expressSession({ secret: 'SayWUT, Crazy Boris?', 
                                     resave: false, 
                                     saveUninitialized: false }));
app.use(passport.initialize());
app.use(passport.session());

/* Pull in the auth code */
auth = require('./auth.js');


/* Now that we have auth code initialized, pass a middlewares */
/* around globally in the req object */
app.use(function(req, res, next) {
	req.authmiddleware = auth.middleware;
	next();
});

/* Static landing pages are served from ./static */
app.use('/', express.static('static'));

app.get('/api', function (req, res) {
  res.send('Say Hi, World!');
});

/* The LimitUser authorization middleware depends on */
/* req.params.userid being defined. */

app.get('/api/profile/:profileid', auth.middleware.AuthGetLimitProfile,  function(req, res){
  var id = req.params.profileid;
  req.db.profile.Profile.find({profileid: id}, function(err, n){
	res.json(n);
  });
});

//Add in code to get a profile from a user id

app.get('/api/bizcard/:profileid', auth.middleware.AuthGetLimitProfile,  function(req, res){
  var id = req.params.profileid;
  req.db.profile.BusinessCards.find({ProfileId: id}, function(err, n){
	res.json(n);
  });
});

app.get('/api/AverageRatings/:userid/:RatingWho', function(req, res){
  var user = req.params.userid;
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


/* GodMode API for admin pages */
var godmode = require('./godmode/godmode.js');
//app.use('/godmode', express.static('godmode/web/'));



var server = app.listen(80, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('SayHi server listening at http://%s:%s', host, port);
});

//Later:
///https://developers.google.com/+/web/api/rest/oauth#login-scopes
//https://developers.google.com/+/features/play-installs
