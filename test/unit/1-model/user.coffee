env = require '../../env.coffee'
Promise = require 'bluebird'

describe 'model', ->
  @timeout env.timeout
  
  tokens = null
  users = env.users
  
  before ->
    env.getTokens()
      .then (res) ->
        tokens = res