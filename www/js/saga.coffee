{ put, select, race, takeEvery } = require 'redux-saga/effects'
{ User } = require './model.coffee'
{ toastr } = require 'react-redux-toastr'

module.exports = ->
  yield race [
    yield takeEvery 'user.list', (action) ->
      try
        User.users = User.mergeAll User.users, yield User.fetchAll()
        yield put
          type: 'user.list.ok'
          data: 
            users: User.users
      catch error
        toastr.error error.toString()
    yield takeEvery 'user.expandAll', ->
      try
        User.users = yield User.fetchNode()
        yield put
          type: 'user.expandAll.ok'
          data:
            users: User.users
      catch error
        toastr.error error.toString()
    yield takeEvery 'user.create', (action) ->
      try 
        user = User email: action.email
        user = yield user.save()
        User.users = User.merge User.users, user
        yield put
          type: 'user.create.ok'
          data:
            users: User.users
            user: User.user
      catch error
        toastr.error error.toString()
    yield takeEvery 'user.expand', (action) ->
      try
        User.user = yield User.fetchOne action.email
        User.users = User.merge User.users, User.user
        yield put
          type: 'user.expand.ok'
          data: 
            users: User.users
            user: User.user
      catch error
        toastr.error error.toString()
    yield takeEvery 'user.update', (action) ->
      try
        { email, supervisor } = action
        User.user = User.find User.users, email: email
        oldSup = User.user.supervisor
        newSup = User.find User.users, email: supervisor
        if oldSup?
          oldSup = User.find User.users, oldSup
          yield oldSup.delSubordinate email: email
        else
          User.users = _.filter User.users, (user) ->
            email != user.email
        User.user = yield newSup.addSubordinate email: email
        yield put
          type: 'user.update.ok'
          data:
            user: User.user
            users: User.users
      catch error
        toastr.error error.toString()
    yield takeEvery 'user.delete', (action) ->
      try
        { email } = action
        User.user = User.find User.users, email: email
        yield User.user.destroy()
        if User.user.supervisor?
          yield User.user.supervisor.delSubordinate User.user
        else
          User.users = _.filter User.users, (user) ->
            user.email != User.user.email
        yield put
          type: 'user.delete.ok'
          data:
            user: User.user
            users: User.users
        yield put
          type: 'user.list'
      catch error
        toastr.error error.toString()
  ]
