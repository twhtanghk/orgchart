assert = require 'assert'
req = require 'supertest-as-promised'
oauth2 = require 'oauth2_client'
Promise = require 'bluebird'

[
  'USER1_ID'
  'USER1_SECRET'
  'USER2_ID'
  'USER2_SECRET'
  'CLIENT_ID'
  'CLIENT_SECRET'
  'TOKENURL'
  'VERIFYURL'
  'SCOPE'
].map (name) ->
  assert name of process.env, "process.env.#{name} not yet defined"

describe 'user', ->
  users = [
    { id: process.env.USER1_ID, secret: process.env.USER1_SECRET }
    { id: process.env.USER2_ID, secret: process.env.USER2_SECRET }
  ]

  before ->
    client =
      id: process.env.CLIENT_ID
      secret: process.env.CLIENT_SECRET
    scope = process.env.SCOPE.split ' '
    Promise
      .map users, (user) ->
        oauth2
          .token process.env.TOKENURL, client, user, scope
          .then (token) ->
            _.extend user, token: token
            oauth2.verify process.env.VERIFYURL, scope, token
          .then (info) ->
            _.extend user, info.user

  it 'update subordinates', ->
    Promise.map users, (user) ->
      req sails.hooks.http.app
        .put '/api/user/me'
        .set 'Authorization', "Bearer #{user.token}"
        .send subordinates: []
        .expect 200

  it 'update supervisor', ->
    req sails.hooks.http.app
      .put '/api/user/me'
      .set 'Authorization', "Bearer #{users[0].token}"
      .send supervisor: users[1].email
      .expect 200
