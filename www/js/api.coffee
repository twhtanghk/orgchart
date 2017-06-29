_ = require 'lodash'
{ all, call, put, select } = require 'redux-saga/effects'
rest = require './model.coffee'
User = require './user.coffee'

orderByEmail = (users) ->
  _.sortBy users, (user) ->
    user.email.toLowerCase()

api =
  users:
    get: ->
      res = yield rest.user.get '/user'
      if not res.error?
        # sort list by email in lowercase
        data = res.data
        data.results = orderByEmail data.results

        return res.data

    expand: (users) ->
      res = yield all users?.map (user) ->
        { data, profile } = yield all
          data: yield api.user.get user.email
          profile: yield api.profile.get user.email
        _.defaults data, profile
        data.subordinates = yield api.users.expand data.subordinates
        data
      return res

  user:
    post: (email) ->
      res = yield rest.user.post '/user', email: email
      if not res.error?
        yield put
          type: 'users.get'

        return res.data

    get: (email) ->
      res = yield rest.user.get "/user/#{email}"
      if not res.error?
        # sort subordinates by email in lowercase
        res.data.subordinates = orderByEmail res.data.subordinates

        return res.data

    put: (email, supervisor) ->
      res = yield rest.user.put "/user/#{email}", supervisor: supervisor
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

        return res.data

    del: (email) ->
      res = yield rest.user.del "/user/#{email}"
      if not res.error?
        # refresh all root nodes
        yield put
          type: 'users.get'

        return res.data

  profile:
    get: (email) ->
      res = yield rest.profile.get "/user/profile/#{email}"

      return res.data

module.exports =
  users:
    get: ->
      users = yield api.users.get()
      profiles = yield all users.results.map (user) ->
        call api.profile.get, user.email
      if users?
        yield put
          type: 'users.get.ok' 
          data: 
            count: users.count
            results: users.results.map (user, i) ->
              _.defaults user, profiles[i]

    expand: (users) ->
      res = yield api.users.expand users
      if res?
        yield put
          type: 'users.expand.ok'
          data: res

  user:
    post: (email) ->
      res = yield api.user.post email
      if res?
        yield put
          type: 'user.post.ok'
          data: res

    get: (email) ->
      res = yield all [
        call api.user.get, email
        call api.profile.get, email
      ]
      if res[0]?
        yield put
          type: 'user.get.ok'
          data: _.defaults res[0], res[1]

    put: (email, supervisor) ->
      res = yield api.user.put email, supervisor
      if res?
        yield put
          type: 'user.put.ok'
          data: res

    del: (email) ->
      res = yield api.user.del email
      if res?
        yield put
          type: 'user.del.ok'
          data: res
