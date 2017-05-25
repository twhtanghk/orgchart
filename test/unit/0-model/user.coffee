assert = require 'assert'
Promise = require 'bluebird'
req = Promise.promisifyAll require 'needle'
url = require 'url'
path = require 'path'
_ = require 'lodash'

[ 'AUTHURL' ].map (name) ->
  assert name of process.env, "process.env.#{name} not yet defined"

userUrl = ->
  userUrl = url.parse process.env.AUTHURL
  url.format _.extend pathname: '/auth/api/users/', _.pick(userUrl, 'protocol', 'auth', 'host')

oauthUsers = (url = userUrl()) ->
  req
    .getAsync url,
      headers:
        Authorization: "Bearer #{users[0].token}"
    .then (res) ->
      if res.statusCode != 200
        return Promise.reject res.body
      users: res.body.results
      next: res.body.next
    .then (res) ->
      if res.next?
        return oauthUsers res.next
          .then (nextRes) ->
            users: res.users.concat nextRes.users
            next: nextRes.next
      res
  
describe 'user', ->
  it 'create', ->
    oauthUsers()
      .then (res) ->
        Promise.map res.users, (user) ->
          user = _.pick user, 'email' 
          sails.models.user.findOrCreate user, user
