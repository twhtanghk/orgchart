_ = require 'lodash'
{ race, call, put, select, takeEvery } = require 'redux-saga/effects'
api = require './model.coffee'
User = require './user.coffee'

users = 
  get: ->
    yield takeEvery 'users.get', (action) ->
      res = yield api.get '/user'
      if not res.error?
        # sort list by email in lowercase
        data = res.data
        data.results = _.sortBy data.results, (user) ->
          user.email.toLowerCase()

        yield put
          type: 'users.get.ok'
          data: data

user =
  post: ->
    yield takeEvery 'user.post', (action) ->
      res = yield api.post '/user', email: action.email
      if not res.error?
        yield put 
          type: 'users.get'
          email: action.email

        yield put
          type: 'user.post.ok'
          data: res.data
  get: ->
    yield takeEvery 'user.get', (action) ->
      res = yield api.get "/user/#{action.email}"
      if not res.error?
        # sort subordinates by email in lowercase
        res.data.subordinates = _.sortBy res.data.subordinates, (user) ->
          user.email.toLowerCase()

        yield put
          type: 'user.get.ok'
          data: res.data
  put: ->
    yield takeEvery 'user.put', (action) ->
      res = yield api.put "/user/#{action.email}", supervisor: action.supervisor
      if not res.error?
        # refresh existing and new supervisor
        users = yield select (state) ->
          state.data.users
        supervisor = User.util.find(res.data, users).supervisor
        supervisor = supervisor?.email || supervisor
        if supervisor?
          yield put
            type: 'user.get'
            email: supervisor
        else
          yield put
            type: 'users.get'
        yield put
          type: 'user.get'
          email: res.data.supervisor.email

        yield put
          type: 'user.put.ok'
          data: res.data
  del: ->
    yield takeEvery 'user.del', (action) ->
      res = yield api.del "/user/#{action.email}"
      if not res.error?
        yield put
          type: 'users.get'

        yield put
          type: 'user.del.ok'
          data: res.data

module.exports = ->
  yield race [
    call users.get
    call user.post
    call user.get
    call user.put
    call user.del
  ]
