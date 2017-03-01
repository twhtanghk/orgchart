env = require ('../../env.coffee')

describe 'model', ->
  createdBy = null

  it 'create user', ->
    sails.models.user
      .create
        username: env.users[0].username, url: env.users[0].url, email: env.users[0].email
      .then (user) ->
        createdBy = user

  it 'update supervisor', ->
    sails.models.user
      .update {username: createdBy.username}, {supervisor: {username: env.users[1].username, url: env.users[1].url, email: env.users[1].email}}
      .then (user) ->
         createdBy = user
         return

  it 'get user', ->
    sails.models.user
      .find
         email: createdBy.email
      .then (user) ->
         console.log user

  it 'delete user', ->
    sails.models.user
      .destroy()
      .then ->
         return
