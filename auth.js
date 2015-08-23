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

passport.use(new LocalStrategy({ passReqToCallback: true, session: false},
	function(req, username, password, done) {
		req.db.profile.Users.findOne({username : username}, function(err, user){
			if (err) {return done(err);}
			if(!user) {
				return done(null, false, {message: 'User not found'});
			}
			bcrypt.compare(password, user.password, function(err, res) {
				if (res == false){
					return done(null, false, 
					     {message: 'Incorrect password.'});
				}
			});
			return done(null, user);
		});
		//stuff to lookup user
		//http://passportjs.org/docs
		//https://github.com/ncb000gt/node.bcrypt.js/
	}
));

//app.use(flash());
app.use(require('body-parser').urlencoded({ extended: true }));
app.use(passport.initialize());


app.get('/login', function(req, res) {
	//console.log(flash('error'));
	res.sendFile(path.join(__dirname, '/static/login.html') )
});

app.post('/login', passport.authenticate('local'), 
	function(req, res){
		res.redirect('/login/' + req.user.username);
	}
);


app.get('/logout', function(req, res) {
	req.logout();
	res.redirect('/');
});




/*
// Treat this as a constructor.
module.exports = function(papp) {

	//Copy app into global for file
	app = papp;
	db = papp.settings.db
	initializeauth();	

	//return { 
	//	 pass: passport
	//}
	//Return passport
	//Return references to all the vars...

};




*/


