_ = require 'lodash'
req = require 'supertest'
Promise = require 'bluebird'

describe 'user', ->
  before ->
    Promise.map users, (user) ->
      req sails.hooks.http.app
        .post '/api/user'
        .set 'Authorization', "Bearer #{users[0].token}"
        .send email: user.email
        .then ({body}) ->
          _.extend user, body

  it 'update supervisor by owner', ->
    req sails.hooks.http.app
      .post '/api/user'
      .set 'Authorization', "Bearer #{users[1].token}"
      .send 
        email: users[1].email
        supervisor: users[0].id
      .expect 200

  it 'check cyclic supervisor by owner', ->
    req sails.hooks.http.app
      .post '/api/user'
      .set 'Authorization', "Bearer #{users[0].token}"
      .send 
        email: users[0].email
        supervisor: users[1].id
      .expect 500

  it 'update myself as supervisor by owner', ->
    req sails.hooks.http.app
      .post '/api/user'
      .set 'Authorization', "Bearer #{users[1].token}"
      .send 
        email: users[1].email
        supervisor: users[1].id
      .expect 500

  it 'update supervisor by admin', ->
    req sails.hooks.http.app
      .post "/api/user"
      .set 'Authorization', "Bearer #{users[0].token}"
      .send
        email: users[1].email
        supervisor: users[0].id
      .expect 200

  it 'update supervisor by non-admin', ->
    req sails.hooks.http.app
      .post "/api/user"
      .set 'Authorization', "Bearer #{users[1].token}"
      .send
        email: users[0].email
        supervisor: users[1].id
      .expect 403
