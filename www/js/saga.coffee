_ = require 'lodash'
{ race, call, put, select, takeEvery } = require 'redux-saga/effects'
api = require './model.coffee'
User = require './user.coffee'

users = 
  get: ->
    yield takeEvery 'users.get', (action) ->
      res = yield api.get '/user'
      action = 
        if res.error?
          type: 'users.get.err'
          error: res.error
        else
          # sort list by email in lowercase
          data = res.data
          data.results = _.sortBy data.results, (user) ->
            user.email.toLowerCase()

          type: 'users.get.ok'
          data: data
      yield put action 

user =
  get: ->
    yield takeEvery 'user.get', (action) ->
      res = yield api.get "/user/#{action.email}"
      action = 
        if res.error?
          type: 'user.get.err'
          error: res.error
        else
          type: 'user.get.ok'
          data: yield res.data
      yield put action
  put: ->
    yield takeEvery 'user.put', (action) ->
      res = yield api.put "/user/#{action.email}", supervisor: action.supervisor
      action = 
        if res.error?
          # clear error or token
          # if existing error is access_denied or Unauthorized
          if res.error in ['access_denied', 'Unauthorized']
            yield put type: 'logout'

          type: 'user.put.err'
          error: res.error
        else
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

          type: 'user.put.ok'
          data: yield res.data
      yield put action

module.exports = ->
  yield race [
    call users.get
    call user.get
    call user.put
  ]
