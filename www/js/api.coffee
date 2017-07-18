_ = require 'lodash'
{ all, call, put, select } = require 'redux-saga/effects'
stampCreator = require './stamp.coffee'
{ util } = require './user.coffee'
{ toastr } = require 'react-redux-toastr'
update = require 'react-addons-update'
stampit = require 'stampit'

ProfileStamp = stampCreator "#{process.env.PROFILEURL}/api/user/profile"

UserStamp = stampCreator "#{location.href}/api/user"
User = UserStamp
  .methods
    getStamp: ->
      User

    isNew: ->
      not @id?

    parse: (data, opts) ->
      update data,
        subordinates:
          $set: User.order(data.subordinates).map (user) ->
            User user, opts
      
    fetch: (opts) ->
      res = yield UserStamp.compose.methods.fetch.call @, opts
      User.user = User res.data, opts
      User.merge User.users, User.user
      yield put
        type: 'user.getOne.ok'

    save: (values, opts) ->
      action = if @isNew() then 'post' else 'put'
      oldSup = @supervisor
      res = yield UserStamp.compose.methods.save.call @, values, opts
      User.user = User res.data, opts
      if oldSup
        User.users = User.merge User.users, User.user
      else
        # reload root nodes
        yield put
          type: 'user.getAll'
      yield put
        type: "user.#{action}.ok"

    getFullName: ->
      {name, username, email} = @
      """
        #{name?.given || ''} #{name?.middle || ''} #{name?.family || ''}
      """.trim() || username || email

    getTitle: ->
      "#{@organization?.name || ''} #{@title || ''}".trim()

    getDisplayName: ->
      "#{@getFullName()} #{@getTitle()}".trim()

    extend: (user) ->
      _.extend @, user 
  .statics
    idAttribute: 'email'

    users:
      count: 0
      results: []

    user: {}

    bfs: (users) ->
      for user in users
        yield user
        if user.subordinates?.length
          yield from @bfs user.subordinates

    order: (users, field = 'email') ->
      _.sortBy users, (user) ->
        user[field].toLowerCase()

    find: (users, user) ->
      for value from @bfs users.results
        if value.email == user.email
          return value
      return null

    merge: (users, user) ->
      for value from @bfs users.results
        if value.email == user.email
          value.extend user
          return users
      # if user not exist, put it as root node
      users =
        update users,
          count:
            $set: users.count + 1
          results:
            $apply: =>
              users.results.push user
              @order users.results

    fetchAll: (data, opts) ->
      res = yield UserStamp.fetchAll data, opts
      @users = update res.data,
        results: 
          $set: @order(res.data.results).map (user) ->
            User user, opts
      yield put 
        type: 'user.getAll.ok'
        data: @users
  
module.exports =
  User: User
