/* Authorization strategies, middlewares, and setup 
 *
 * SayHi will support Google+, Twitter, and Facebook Signin
 */



var bcrypt = require('bcrypt-nodejs');
var passport = require('passport');

//Import strategies
var LocalStrategy = require('passport-local').Strategy;
var GoogleStrategy = require('passport-google-oauth').OAuthStrategy;
var FacebookStrategy = require('passport-facebook').Strategy

var app;
var db;

passport.use(new LocalStrategy(
	function(username, password, done) {
		//stuff to lookup user
		//http://passportjs.org/docs
		//https://github.com/ncb000gt/node.bcrypt.js/
	});
}







// Treat this as a constructor.
module.exports = function(papp) {

	//Copy app into global for file
	app = papp;
	db = papp.settings.db

	//Return passport
	//Return references to all the vars...

};




//Local Strategy



