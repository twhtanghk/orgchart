_ = require 'lodash'
Promise = require 'bluebird'

module.exports =

  autoPK: false
  
  tableName:  'user'

  schema: true
  
  attributes:

    email:
      type: 'email'
      unique: true
      required: true
      primaryKey: true

    name:
      type: 'json'

    organization:
      type: 'string'

    title:
      type: 'string'

    phone:
      type: 'json'

    supervisor:
      model: 'user'

    subordinates:
      collection: 'user'
      via: 'supervisor'

    # populate line managers of this user
    lineManagers: ->
      if @supervisor?
        sails.models.user
          .findOne _.pick @, 'email'
          .populate 'supervisor'
          .then (curr) ->
            curr.supervisor.lineManagers()
          .then (supervisor) ->
            curr.supervisor = supervisor
            return curr
      else
        Promise.resolve @

    # return if this user is supervisor of the specified user
    isSupervisor: (user) ->
      if user.supervisor?
        sails.models.user
          .findOne _.pick user, 'email'
          .populate 'supervisor'
          .then (curr) ->
            if not curr?
              retrun false
            else if curr.supervisor?.email == @mail
              return true
            else
              @isSupervisor curr.supervisor
      else
        Promise.resolve false
          
    # return if this user subordinate of the specified user
    isSubordinate: (user) ->
      sails.models.user
        .findOne _.pick user, 'email'
        .then (curr) =>
          if not curr?
            return false
          else
            curr?.isSupervisor @
          
  beforeValidate: (values, cb) ->
    if values.supervisor?
      if values.supervisor == values.email
        return cb new Error "assign user myself as supervisor"
      sails.models.user
        .findOne email: values.email
        .then (curr) ->
          if not curr?
            cb()
          else
            curr
              .isSupervisor(email: values.supervisor)
              .then (isSupervisor) ->
                if isSupervisor
                  cb new Error "assign existing subordinate as supervisor"
                else
                  cb()
    else
      cb()

  beforeDestroy: (criteria, cb) ->
    sails.models.user
      .find criteria
      .populate 'subordinates'
      .then (users) ->
        Promise.map users, (user) ->
          Promise.map user.subordinates, (subordinate) ->
            subordinate.supervisor = null
            subordinate.save().then Promise.resolve, Promise.reject
      .then ->
        cb()
      .catch cb

  updateCreate: (value) ->
    @findOne email: value.email
      .then (user) =>
        if user?
          @update email: value.email, _.pick(value, 'name', 'organization', 'title', 'phone')
        else
          @create value
      .then =>
        @findOne email: value.email
