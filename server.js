var express = require('express');
var app = express();

app.use('/', express.static('static'));
app.get('/api', function (req, res) {
  res.send('Hello World!');
});

var server = app.listen(80, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});
