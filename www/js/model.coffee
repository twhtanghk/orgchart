_ = require 'lodash'
{ all, call, put, select } = require 'redux-saga/effects'
stampCreator = require 'saga-model'
{ util } = require './user.coffee'
{ toastr } = require 'react-redux-toastr'
stampit = require 'stampit'

ProfileStamp = stampCreator "#{process.env.PROFILEURL}/api/user/profile"

UserStamp = stampCreator "#{location.href}/api/user"
User = UserStamp
  .methods
    getStamp: ->
      User

    isNew: ->
      not @id?

    parse: (data) ->
      if data.supervisor?
        data.supervisor = User if typeof data.supervisor == 'string' then email: data.supervisor else data.supervisor
      data.subordinates = User.order(data.subordinates).map (user) ->
        User user
      data
      
    fetch: ->
      { data } = yield UserStamp.compose.methods.fetch.call @
      User data

    save: (values) ->
      action = if @isNew() then 'post' else 'put'
      oldSup = @supervisor
      res = yield UserStamp.compose.methods.save.call @, values
      User res.data

    getFullName: ->
      {name, username, email} = @
      """
        #{name?.given || ''} #{name?.middle || ''} #{name?.family || ''}
      """.trim() || username || email

    getTitle: ->
      "#{@organization?.name || ''} #{@title || ''}".trim()

    getDisplayName: ->
      "#{@getFullName()} #{@getTitle()}".trim()

    getTotal: ->
      ret = 1
      cb = (sum, node) ->
        sum + node.getTotal()
      @subordinates?.reduce cb, ret

    extend: (user) ->
      _.extend @, user

    addSubordinate: (user) ->
      res = yield @getStamp().api.post User.urlSubordinate(@, user)
      @subordinates = User.order res.data.subordinates.map (node) ->
        User node
      @

    delSubordinate: (user) ->
      res = yield @getStamp().api.del User.urlSubordinate(@, user)
      @subordinates = _.filter @subordinates, (node) ->
        node.email != user.email
      @

  .statics
    idAttribute: 'email'

    user: {}

    users: []

    urlSubordinate: (user, subordinate) ->
      @url "#{user[@idAttribute]}/subordinates/#{subordinate[@idAttribute]}"

    bfs: (users) ->
      for user in users
        yield user
        if user.subordinates?.length
          yield from @bfs user.subordinates

    order: (users, field = 'email') ->
      _.sortBy users, (user) ->
        user[field].toLowerCase()

    find: (users, user) ->
      for value from @bfs users
        if value.email == user.email
          return value
      return null

    merge: (users, user) ->
      for value from @bfs users
        if value.email == user.email
          value.extend user
          return users
      # if user not exist, put it as root node
      users.push user
      @order users

    mergeAll: (users, list) ->
      cb = (res, user) =>
        @merge res, user
      list.reduce cb, users

    fetchAll: (data) ->
      res = yield UserStamp.fetchAll data
      @order res.data.map (user) ->
        User user

    fetchNode: (node = null) ->
      users = yield @fetchAll node
      for node in users
        if node.subordinates?.length
          node.subordinates = yield @fetchNode email: node.subordinates.map (user) ->
            user.email
        node
          
module.exports =
  User: User
