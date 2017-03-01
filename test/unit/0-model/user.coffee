describe 'model', ->
  createdBy = null

  it 'create user', ->
    sails.models.user
      .create
        username: 'user1', url: 'user1@ogcio.gov.hk', email: 'user1@ogcio.gov.hk'
      .then (user) ->
        createdBy = user

  it 'update supervisor', ->
    sails.models.user
      .update {username: createdBy.username}, {supervisor: {username: 'user2', url: 'user2@ogcio.gov.hk', email: 'user2@ogcio.gov.hk'}}
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
