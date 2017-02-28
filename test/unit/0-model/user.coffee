env = require '../../env.coffee'
Promise = require 'bluebird'

describe 'model', ->
  createdBy = null
  vmlist = ['test1', 'test2']

  it 'create user', ->
    sails.models.user
      .find
        email: 'user@abc.com'
      .then (user) ->
        createdBy = user