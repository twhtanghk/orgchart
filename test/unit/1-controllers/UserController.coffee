env = require '../../env.coffee'
req = require 'supertest-as-promised'    
path = require 'path'
util = require 'util'
_ = require 'lodash'
fs = require 'fs'
Promise = require 'bluebird'

describe 'UserController', ->
  @timeout env.timeout
  
  token = null
  user = null
  
  before ->
    env.getToken()
      .then (res) ->
        token = res
        env.getUser()
      .then (res) ->
        user = res

  it 'update supervisor', (done) ->
    req sails.hooks.http.app
      .put "/api/user/#{user.id}"
      .set 'Authorization', "Bearer #{token}"
      .send
        supervisor: {username: 'user3', url: 'user3@abc.com', email: 'user3@abc.com'} 
      .expect 200
      .then (res) ->
         setTimeout (-> done()), 1000
