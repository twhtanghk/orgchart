req = require 'supertest-as-promised'
oauth2 = require 'sails_client'

describe 'user', ->
  token = null

  before ->
    client =
      id: process.env.CLIENT_ID
      secret: process.env.CLIENT_SECRET
    user =
      id: process.env.USER_ID
      secret: process.env.USER_SECRET
    scope = process.env.TOKENURL.split ' '
    oauth2
      .token process.env.TOKEN_URL, client, user, scope
      .then (t) ->
        token = t

  it "create", ->
    req sails.hooks.http.app
      .post '/api/user'
      .set 'Authorization', "Bearer #{token}"
      .send email: 'user@abc.com'
      .expect 201
