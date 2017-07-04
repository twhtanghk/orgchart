_ = require 'lodash'
{ all, call, put, select } = require 'redux-saga/effects'
rest = require './model.coffee'
{ util } = require './user.coffee'

orderByEmail = (users) ->
  _.sortBy users, (user) ->
    user.email.toLowerCase()

class User
  @url:
      user: '/user'
      profile: '/user/profile'

  constructor: (props) ->
    _.extend @, props
    @subordinates = orderByEmail @subordinates
    @subordinates = @subordinates.map (user) ->
      new User user

  addProps: (props) ->
    _.extend @, props

  getFullName: ->
    """
      #{@name?.given || ''} #{@name?.middle || ''} #{@name?.family || ''}
    """.trim() || @username || @email

  getTitle: ->
    "#{@organization?.name || ''} #{@title || ''}".trim()

  getDisplayName: ->
    "#{@getFullName()} #{@getTitle()}".trim()

  @post: (email) ->
    res = yield rest.user.post User.url.user, email: email
    if not res.error?
      # reload root nodes
      yield put
        type: 'user.getAll'

      yield User.getOne email

  @expand: (users) ->
    res = yield all users?.map (user) ->
      user = yield User.getOne user.email
      yield User.expand user.subordinates

  @getAll: ->
    users = yield rest.user.get User.url.user
    if users.detail.ok
      users = users.data
      users.results = orderByEmail users.results
      users.results = users.results.map (user) ->
        new User user
      profiles = yield all users.results.map (user) ->
        res = yield rest.profile.get "#{User.url.profile}/#{user.email}"
        res
      yield put
        type: 'user.getAll.ok'
        data:
          count: users.count
          results: users.results.map (user, i) ->
            user.addProps profiles[i].data

  @getOne: (email) ->
    [user, profile] = yield all [
      rest.user.get "#{User.url.user}/#{email}"
      rest.profile.get "#{User.url.profile}/#{email}"
    ]
    if user.detail.ok
      user = new User user.data
      user.addProps profile.data
      yield put
        type: 'user.getOne.ok'
        data: user
      user

  @put: (email, supervisor) ->
    res = yield rest.user.put "#{User.url.user}/#{email}", 
      supervisor: supervisor
    if res.detail.ok
      # reload existing supervisor
      users = yield select (state) ->
        state.data.users
      supervisor = util.find(res.data, users).supervisor
      supervisor = supervisor?.email || supervisor
      if supervisor?
        yield User.getOne supervisor
      else
        yield User.getAll()
      # reload new supervisor
      yield User.getOne res.data.supervisor.email
      # reload current updated node
      yield User.getOne res.data.email
      
  @del: (email) ->
    res = yield rest.user.del "#{User.url.user}/#{email}"
    if res.detail.ok
      if res.data.supervisor?
        yield User.getOne res.data.supervisor.email
      # reload root nodes
      yield User.getAll()

module.exports =
  User: User
