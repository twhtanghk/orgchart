{ select, call, race, takeEvery } = require 'redux-saga/effects'
api = require './api.coffee'

module.exports = ->
  yield race [
    yield takeEvery 'users.get', ->
      api.users.get()
    yield takeEvery 'users.expandAll', ->
      users = yield select (state) ->
        state.data.users.results
      yield api.users.expand users
    yield takeEvery 'user.post', (action) ->
      api.user.post action.email
    yield takeEvery 'user.get', (action) ->
      api.user.get action.email
    yield takeEvery 'user.put', (action) ->
      api.user.put action.email, action.supervisor
    yield takeEvery 'user.del', (action) ->
      api.user.del action.email
  ]
