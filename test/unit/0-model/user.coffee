describe 'model', ->
  createdBy = null

  it 'create user', ->
    sails.models.user
      .create
        username: 'jokyip', url: 'jokyip@ogcio.gov.hk', email: 'jokyip@ogcio.gov.hk'
      .then (user) ->
        createdBy = user

  it 'update supervisor', ->
    sails.models.user
      .update {username: createdBy.username}, {supervisor: {username: 'ewnchui', url: 'ewnchui@ogcio.gov.hk', email: 'ewnchui@ogcio.gov.hk'}}
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
