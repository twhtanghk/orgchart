_ = require 'lodash'
{ race, call, put, takeEvery } = require 'redux-saga/effects'
api = require './model.coffee'

module.exports = ->

users = 
  get: ->
    yield takeEvery 'users.get', (action) ->
      res = yield api.get '/user'
      if res.ok
        data = yield res.json()
        data.results = _.sortBy data.results, (user) ->
          user.email.toLowerCase()
        yield put Object.assign 
          type: 'users.get.ok'
          data: data
      else
        yield put Object.assign type: 'users.get.err', res.body

user =
  get: ->
    yield takeEvery 'user.get', (action) ->
      yield api.get "/user/#{action.email}"

module.exports = ->
  yield race [
    call users.get
    call user.get
  ]
