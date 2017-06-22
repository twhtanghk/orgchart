_ = require 'lodash'
{ all, call, put, select } = require 'redux-saga/effects'
rest = require './model.coffee'
User = require './user.coffee'

orderByEmail = (users) ->
  _.sortBy users, (user) ->
    user.email.toLowerCase()

module.exports =
  users:
    get: ->
      res = yield rest.get '/user'
      if not res.error?
        # sort list by email in lowercase
        data = res.data
        data.results = orderByEmail data.results

        yield put
          type: 'users.get.ok'
          data: data

  user:
    post: (email) ->
      res = yield rest.post '/user', email: email
      if not res.error?
        yield put
          type: 'users.get'

        yield put
          type: 'user.post.ok'
          data: res.data
    get: (email) ->
      res = yield rest.get "/user/#{email}"
      if not res.error?
        # sort subordinates by email in lowercase
        res.data.subordinates = orderByEmail res.data.subordinates

        yield put
          type: 'user.get.ok'
          data: res.data
    put: (email, supervisor) ->
      res = yield rest.put "/user/#{email}", supervisor: supervisor
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
    del: (email) ->
      res = yield rest.del "/user/#{email}"
      if not res.error?
        # refresh all root nodes
        yield put
          type: 'users.get'

        # refresh all subordinates
        yield all res.data.subordinates.map (subordinate) ->
          yield put
            type: 'user.get'
            email: subordinate.email

        yield put
          type: 'user.del.ok'
          data: res.data
