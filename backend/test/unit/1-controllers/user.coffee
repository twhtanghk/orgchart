req = require 'supertest-as-promised'
Promise = require 'bluebird'

describe 'user', ->
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
