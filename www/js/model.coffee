fetch = require 'isomorphic-fetch'
reduxApi = require 'redux-api'
adapter = require 'redux-api/lib/adapters/fetch'

rest = reduxApi
  users: 
    url: '/api/user'
  user:
    url: '/api/user/:email'
    crud: true
rest
  .use 'fetch', adapter fetch
  .use 'server', true
  .use 'rootUrl', 'http://mppsrc.ogcio.hksarg/twhtang/mpp'
  .use 'options', ->
    headers:
      Accept: 'application/json'
      'Content-Type': 'application/json'

module.exports = rest
