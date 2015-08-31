/* API for the GodMode front-end */


var authMiddleware = function(req, res, next) {
        req.authmiddleware.AuthGodMode(req, res, next);
        };



/* Front-end routing */
app.use('/godmode', authMiddleware, express.static('godmode/web/'));


/* User & Profile information is available at */
/* /auth/me/user and /auth/me/profile         */

/* Get all the data for map dumping! */
app.get('/godmode/location/all', authMiddleware, function(req, res){
  req.db.godmode.AllPoints(function(err, n){
        console.log(err);
        res.json(n);
  });
});




