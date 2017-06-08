_ = require 'lodash'
fetch = require 'isomorphic-fetch'
reduxApi = require 'redux-api'
adapter = require 'redux-api/lib/adapters/fetch'
update = require 'react-addons-update'

history = []

bfs = (root, cb) ->
 root = cb root
 root.subordinates = root.subordinates?.map (node) ->
   bfs node, cb
 root

rest = reduxApi
  users: 
    url: '/api/user'
    transformer: (data = {}, prevData, action) ->
      update data,
        results:
          $apply: (users) ->
            _.sortBy users, (user) ->
              user.email.toLowerCase()
    reducer: (state, action) ->
      if action.type == rest.events.user.actionSuccess
        data = action.data
        update state, data: results: $merge: state?.data?.results?.map (root) ->
          bfs root, (node) ->
            if node.email == data.email
              update node, $merge: data
            else
              node
      else
        state || {}
  user:
    url: '/api/user/:email'
    crud: true
    transformer: (data = {}, prevData, action) ->
      update data,
        subordinates:
          $apply: (users) ->
            _.sortBy users, (user) ->
              user.email.toLowerCase()

rest
  .use 'fetch', adapter fetch
  .use 'server', true
  .use 'rootUrl', location.href
  .use 'options', (url, params, getState) ->
    headers:
      Accept: 'application/json'
      'Content-Type': 'application/json'
      Authorization: "Bearer #{getState().auth.token}"

module.exports = rest
