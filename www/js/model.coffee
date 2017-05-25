_ = require 'lodash'
fetch = require 'isomorphic-fetch'
reduxApi = require 'redux-api'
adapter = require 'redux-api/lib/adapters/fetch'
update = require 'react-addons-update'

rest = reduxApi
  users: 
    url: '/api/user'
    reducer: (state, action) ->
      newstate = state
      if action.type == rest.events.user.actionSuccess
        newstate = update state,
          data:
            results:
              $apply: (users) ->
                users.map (user) ->
                  if user.email != action.data.email
                    return user
                  update user,
                    $merge: action.data
      newstate || {}
  user:
    url: '/api/user/:email'
    crud: true
rest
  .use 'fetch', adapter fetch
  .use 'server', true
  .use 'rootUrl', 'http://mppsrc.ogcio.hksarg/twhtang/mpp'
  .use 'options', ->
    headers:
      Accept: 'application/json'
      'Content-Type': 'application/json'

module.exports = rest
