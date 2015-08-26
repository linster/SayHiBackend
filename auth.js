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
				} else {
				/* Now that we've logged in, return a profile */
				req.db.profile.Profile.findone(user.ProfileId, 
					function(err, rprofile) {
						return done(null, rprofile);
					});
				}
			});
		});
	}
));

/* User profile checker for socially logged-in users */
var FindOrCreateUser = function(req, profile, done) {
// The profile object follows this spec:
// http://passportjs.org/docs/profile
req.db.profile.Users.where('SocialType = $1 AND oAuthId = $2', 
	[profile.provider, profile.id], function(err, userrec){
	if (existingrec){
	//We have an existing record of this user.
	//Do return profile table record.
	req.db.profile.Profile.findOne(userrec, function(err, extprof){
		if (err) {/* error out */ done(err)}
		return done(null, extprof);
		});
	} else {
		//First make a profile Id
		req.db.profile.Profile.save(
		   { Nickname: profile.displayName  }, function(err, newprofile){
			req.db.profile.Users.save(
				{ oAuthId: profile.id,
				  SocialType: profile.provider,
				  ProfileId: newprofile.ProfileId},
				function(err, newUser){
					if (err) { return done(err);}
					return done(null, newprofile)
				});
		});
	}
});


/* Google OAuth 2.0 Account Strategy */
/* https://github.com/jaredhanson/passport-google-oauth/blob/master/examples/oauth2/app.js */

assport.use(new GoogleStrategy({
    consumerKey: '761036697909-9p4sln87guk5igdgf787k9g5vfuabai3.apps.googleusercontent.com',
    consumerSecret: 'H2bsH6CCej6ybFCG3YAOaXTJ',
    callbackURL: "http://lagoon.stefanm.ca/auth/google/callback"
  },
  function(token, tokenSecret, profile, done) {
	//Need all sorts of logic on the create user here....
	//See what goodies we can get from here:
	//https://developers.google.com/oauthplayground/?code=4/8iu7vFXoODFkYHw9UdxoK1-3vSxnQrGP7uVkZJ5Oa3E&authuser=0&prompt=consent&session_state=b765fe2dbee8f7779b439bd199cc5e889a37cee3..40dd#

    FindOrCreateUser(req, profile, done);

    /*User.findOrCreate({ googleId: profile.id }, function (err, user) {
      return done(err, user);
    });*/
  }
));

app.get('/auth/google',
  passport.authenticate('google', { scope: 'https://www.googleapis.com/auth/plus.me' }));

app.get('/auth/google/callback', 
  passport.authenticate('google', { failureRedirect: '/auth/login' }),
  function(req, res) {
    // Successful authentication, redirect home.
    res.redirect('/auth/success');
  });






//Should only need to add the new strategy,
//update the serializeUser & deserializeUser methods






/*  Authenticated session persistence */
/*  https://github.com/passport/express-4.x-local-example/blob/master/server.js */

//Change this to serialize on profile records.
passport.serializeUser(function(profile, cb) {
  cb(null, profile.ProfileId);
});

passport.deserializeUser(function(req, id, cb) {
  req.db.profile.Profile.findOne({ProfileId: id}, function (err, profile) {
    if (err) { return cb(err); }
    cb(null, profile);
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
app.get('/auth/login', function(req, res) {
	res.sendFile(path.join(__dirname, '/static/login.html') )
});
/* Handle form postback */
app.post('/auth/login', passport.authenticate('local'), 
	function(req, res){
		res.json(req.user);
		//res.redirect('/login/' + req.user.username);
	}
);
/* Logout Route */
app.get('/auth/logout', function(req, res) {
	req.logout();
	res.redirect('/');
});







