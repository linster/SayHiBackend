/* Authorization strategies, middlewares, and setup 
 *
 * SayHi will support Google+, Twitter, and Facebook Signin
 */

passport = require('passport');
var path = require('path');
var bcrypt = require('bcrypt');

//Import strategies
var LocalStrategy = require('passport-local').Strategy;
var GoogleStrategy = require('passport-google-oauth').OAuthStrategy;
var FacebookStrategy = require('passport-facebook').Strategy

/* Set up strategies */
passport.use(new LocalStrategy({ passReqToCallback: true, session: false},
	function(req, username, password, done) {
		req.db.profile.Users.findOne({username : username}, function(err, user){
			if (err) {return done(err);}
			if(!user) {
				return done(null, false, {message: 'User not found'});
			}
			/* Compare passwords with bcrypt               */
			/* https://github.com/ncb000gt/node.bcrypt.js/ */
			bcrypt.compare(password, user.password, function(err, res) {
				if (res == false){
					return done(null, false, 
					     {message: 'Incorrect password.'});
				}
			});
			//TODO: Might want to move this inside the callback above...
			return done(null, user);
		});
	}
));

/*  Authenticated session persistence */
/*  https://github.com/passport/express-4.x-local-example/blob/master/server.js */

passport.serializeUser(function(user, cb) {
  cb(null, user.Id);
});

passport.deserializeUser(function(id, req, cb) {
  req.db.users.findById(id, function (err, user) {
    if (err) { return cb(err); }
    cb(null, user);
  });
});


/* Set up Express for passport sessions */
app.use(require('body-parser').urlencoded({ extended: true }));
app.use(require('cookie-parser')());
app.use(require('express-session')({ secret: 'SayWUT, Crazy Boris?', 
				     resave: false, 
				     saveUninitialized: false }));

/* Initialize passport */
app.use(passport.initialize());
app.use(passport.session());


/* Serve up static login page */
app.get('/login', function(req, res) {
	res.sendFile(path.join(__dirname, '/static/login.html') )
});
/* Handle form postback */
app.post('/login', passport.authenticate('local'), 
	function(req, res){
		res.redirect('/login/' + req.user.username);
	}
);
/* Logout Route */
app.get('/logout', function(req, res) {
	req.logout();
	res.redirect('/');
});




