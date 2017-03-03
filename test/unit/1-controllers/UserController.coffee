env = require '../../env.coffee'
req = require 'supertest-as-promised'    
path = require 'path'
util = require 'util'
_ = require 'lodash'
fs = require 'fs'
Promise = require 'bluebird'

describe 'UserController', ->
  @timeout env.timeout
  
  tokens = null
  users = null
  
  before ->
    env.getTokens()
      .then (res) ->
        tokens = res

  it 'update supervisor', (done) ->
    req sails.hooks.http.app
      .put '/api/user/me'
      .set 'Authorization', "Bearer #{tokens}"
      .send
        supervisor: {username: 'user3', url: 'user3@abc.com', email: 'user3@abc.com'} 
      .expect 200
      .then (res) ->
         sails.log res.body
         setTimeout (-> done()), 1000
