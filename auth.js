/* Authorization strategies, middlewares, and setup 
 *
 * SayHi will support Google+, Twitter, and Facebook Signin
 */

var path = require('path');
var bcrypt = require('bcrypt');


//Import strategies
var LocalStrategy = require('passport-local').Strategy;
var GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;
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
				req.db.profile.Profile.findOne({profileid: user.profileid}, 
					function(err, rprofile) {
						if (err) {return done(err);}
						return done(null, rprofile);
					});
				}
			});
		});
	}
));

/* User profile checker for socially logged-in users */
var FindOrCreateUser = function(req, profile, done) {
/*  The profile object follows this spec: */
/*   http://passportjs.org/docs/profile   */
req.db.profile.Users.where('socialtype = $1 AND oauthid = $2', 
	[profile.provider, profile.id], function(err, userrec){
	//TODO
	//console.warn('User rec:');
	//console.warn(userrec);
	if (userrec.length > 0){
	/* We have an existing record of this user. */
	/* Return profile table record. */
	req.db.profile.Profile.findOne({profileid: userrec[0].profileid}, function(err, extprof){
		//console.warn('extprof');
		//console.warn(extprof);
		if (err) {/* error out */ console.warn(err); done(err)}
		return done(null, extprof);
		});
	} else {
		//First make a profile Id
		req.db.profile.Profile.save(
		   { Nickname: profile.displayName  }, function(err, newprofile){
			//console.warn('Newprofile:');
			//console.warn(newprofile);
			if (err) { console.log(err); return done(err);}
			req.db.profile.Users.save(
				{ oauthid: profile.id,
				  socialtype: profile.provider,
				  profileid: newprofile.profileid},
				function(err, newUser){
					if (err) { return done(err);}
					return done(null, newprofile)
				});
		});
	}
});};


/* Google OAuth 2.0 Account Strategy */
/* https://github.com/jaredhanson/passport-google-oauth/blob/master/examples/oauth2/app.js */

passport.use(new GoogleStrategy({
    clientID: "761036697909-9p4sln87guk5igdgf787k9g5vfuabai3.apps.googleusercontent.com",
    clientSecret: "H2bsH6CCej6ybFCG3YAOaXTJ",
    callbackURL: "http://lagoon.stefanm.ca/auth/google/callback",
    passReqToCallback: true
  },
  function(req, token, tokenSecret, profile, done) {
	//Need all sorts of logic on the create user here....
	//See what goodies we can get from here:
	//https://developers.google.com/oauthplayground/?code=4/8iu7vFXoODFkYHw9UdxoK1-3vSxnQrGP7uVkZJ5Oa3E&authuser=0&prompt=consent&session_state=b765fe2dbee8f7779b439bd199cc5e889a37cee3..40dd#

    FindOrCreateUser(req, profile, done);

  }
));

app.get('/auth/google',
  passport.authenticate('google', { scope: 'https://www.googleapis.com/auth/plus.me' }),
  function (req, res) {
	console.log('Logged in'); //Should never be called
  }


);

app.get('/auth/google/callback', 
  passport.authenticate('google', { failureRedirect: '/auth/login' }),
  function(req, res) {
    // Successful authentication, redirect home.
	res.json(req.user);
//    res.redirect('/auth/success');
  });



/*  Authenticated session persistence */
/*  https://github.com/passport/express-4.x-local-example/blob/master/server.js */
passport.serializeUser(function(profile, cb) {
  cb(null, profile.profileid);
});

passport.deserializeUser(function(req, id, cb) {
  req.db.profile.Profile.findOne({profileid: id}, function (err, profile) {
    if (err) { return cb(err); }
    cb(null, profile);
  });
});

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


/* Authorization middlewares */
/* Insert these wherever you need to secure endpoints */


/* Use this for GET /api/ endpoints that get info on a user */

authMiddlewares = {

AuthGetLimitUser: function (req, res, next) {
	if (req.isAuthenticated()){
		/* Get userId from profile Id in req.user (our session) */
		req.db.profile.Users.findOne({profileid: req.user.profileid}, 
			function(err, user){
			console.warn('Middleware UserId');
			console.warn(user.Id);
			 if (req.params.userid != user.Id) {
				res.status(403).end();
			 }else{
				return next();
			 }
			}
		);
	}
	res.status(403).end();
	//res.redirect('/auth/login');
},
AuthGetLimitProfile: function (req, res, next) {
	if (req.isAuthenticated()){
		 if (req.params.profileid != req.user.profileid) {
			res.status(403).end();
		 }else{
			return next();
		 }
	}
	//res.status(403).end();
	res.redirect('/auth/login');
},

/* Use this for god mode */
AuthGodMode: function (req, res, next){
	if (req.isAuthenticated()){
		/* Get userId from profile Id in req.user (our session) */
		req.db.profile.Users.findOne({profileid: req.user.profileid}, 
			function(err, user){
			 /* Hardcoded List of who can get into God Mode */
			 /* List of profile.Users.username. For security,*/
			 /* only local-auth users can get into God Mode */
			 var GodList = ['SayHiAdmin', 'io'];

			 if (_.contains(GodList, user.username)){
			     return next();
			 } else {
			     res.status(403).end();
			 }
			}
		);
	}
	//res.status(403).end();
	res.redirect('/auth/login');

}
};

module.exports = { middleware: authMiddlewares};
