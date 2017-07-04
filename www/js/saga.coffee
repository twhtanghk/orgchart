{ select, call, race, takeEvery } = require 'redux-saga/effects'
{ User } = require './api.coffee'

module.exports = ->
  yield race [
    yield takeEvery 'user.getAll', ->
      User.getAll()
    yield takeEvery 'user.expandAll', ->
      users = yield select (state) ->
        state.data.users.results
      yield User.expand users
    yield takeEvery 'user.post', (action) ->
      User.post action.email
    yield takeEvery 'user.getOne', (action) ->
      User.getOne action.email
    yield takeEvery 'user.put', (action) ->
      User.put action.email, action.supervisor
    yield takeEvery 'user.del', (action) ->
      User.del action.email
  ]
