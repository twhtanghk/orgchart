assert = require 'assert'
req = require 'supertest-as-promised'
oauth2 = require 'oauth2_client'
Promise = require 'bluebird'

[
  'USER1_ID'
  'USER1_SECRET'
  'USER2_ID'
  'USER2_SECRET'
  'PASS_CLIENT_ID'
  'PASS_CLIENT_SECRET'
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
  admin = users[0] # assume users[0] to be defined as admin

  before ->
    client =
      id: process.env.PASS_CLIENT_ID
      secret: process.env.PASS_CLIENT_SECRET
    scope = process.env.SCOPE.split ' '
    Promise
      .map users, (user) ->
        oauth2
          .token process.env.TOKENURL, client, user, scope
          .then (token) ->
            _.extend user, token: token
            oauth2.verify process.env.VERIFYURL, scope, token
          .then (curr) ->
            _.extend user, curr.user

  it 'update subordinates', ->
    Promise.map users, (user) ->
      req sails.hooks.http.app
        .put '/api/user/me'
        .set 'Authorization', "Bearer #{user.token}"
        .send {}
        .expect 200

  it 'update supervisor by owner', ->
    req sails.hooks.http.app
      .put '/api/user/me'
      .set 'Authorization', "Bearer #{users[1].token}"
      .send supervisor: users[0].email
      .expect 200

  it 'update myself as supervisor by owner', ->
    req sails.hooks.http.app
      .put '/api/user/me'
      .set 'Authorization', "Bearer #{users[1].token}"
      .send supervisor: users[1].email
      .expect 500

  it 'update supervisor by admin', ->
    req sails.hooks.http.app
      .put "/api/user/#{users[1].email}"
      .set 'Authorization', "Bearer #{users[0].token}"
      .send supervisor: users[0].email
      .expect 200

  it 'update supervisor by non-admin', ->
    req sails.hooks.http.app
      .put "/api/user/#{users[0].email}"
      .set 'Authorization', "Bearer #{users[1].token}"
      .send supervisor: users[1].email
      .expect 403
