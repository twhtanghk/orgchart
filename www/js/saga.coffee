{ select, race, takeEvery } = require 'redux-saga/effects'
{ User } = require './api.coffee'

module.exports = ->
  yield race [
    yield takeEvery 'user.getAll', ->
      User.fetchAll()
    yield takeEvery 'user.expandAll', ->
      users = yield select (state) ->
        state.data.users.results
      yield User.fetchAll email: users
    yield takeEvery 'user.post', (action) ->
      user = User email: action.email
      user.save()
    yield takeEvery 'user.getOne', (action) ->
      User.fetchOne action.email
    yield takeEvery 'user.put', (action) ->
      user = yield select (state) ->
        User.find state.data.users, email: action.email
      if user?
        yield user.save supervisor: action.supervisor
    yield takeEvery 'user.del', (action) ->
      User.del action.email
  ]
