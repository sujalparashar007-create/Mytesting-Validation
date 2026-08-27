const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.send('Egress test OK - PRIVATE_RANGES_ONLY validated');
});
