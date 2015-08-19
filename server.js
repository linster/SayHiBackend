var db_config = require('./config.js');
var express = require('express');
var app = express();
var massive = require("massive");

/* Connect to postgres */
var connectionString = "postgres://" + db_config.user +":"+ db_config.password +"@"+ db_config.host +"/"+ db_config.database
console.log(connectionString);
var massiveInstance = massive.connectSync({connectionString: connectionString});


/* Set up global db reference */
app.set('db', massiveInstance);

app.use('/', express.static('static'));
app.get('/api', function (req, res) {
  res.send('Hello World!');
});

var server = app.listen(80, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});

