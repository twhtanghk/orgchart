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
        env.getUsers()
      .then (res) ->
        users = res

  it 'update supervisor', ->
    req sails.hooks.http.app
      .put '/api/user'
      .set 'Authorization', "Bearer #{tokens[0]}"
      .send
        email: users[1]
      .expect 200
      .then (res) ->
        Promise.resolve