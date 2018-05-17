_ = require 'lodash'
Promise = require 'bluebird'

module.exports =

  tableName:  'user'

  schema: true
  
  attributes:

    id:
      type: 'string'
      columnName: '_id'

    email:
      type: 'string'
      unique: true

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

  isSupervisor: (supervisor, subordinate) ->
    if not ('supervisor' of subordinate and subordinate.supervisor?)
      return false
    else if subordinate.supervisor?.id == supervisor?.id
      return true
    else
      @findOne id: subordinate.supervisor.id || subordinate.supervisor
        .populate 'supervisor'
        .then (user) ->
          sails.models.user.isSupervisor supervisor, user

  selfSupervisor: (values) ->
    if 'supervisor' of values and 'id' of values and values.supervisor? and values.id? and values.supervisor == values.id
      throw new Error 'assign self as supervisor'

  cyclicSupervisor: (values) ->
    if values.supervisor?
      Promise
        .all [
          @findOne id: values.supervisor?.id || values.supervisor
          @findOne email: values.email
        ]
        .then (supervisor, subordinate) ->
          if sails.models.user.isSupervisor subordinate, supervisor
            throw new Error 'assign existing suborindate as supervisor'
 
  beforeCreate: (values, cb) ->
    @beforeUpdate values, cb

  beforeUpdate: (values, cb) ->
    Promise
      .all [
        sails.models.user.selfSupervisor values
        sails.models.user.cyclicSupervisor values
      ]
      .then ->
        cb()
      .catch cb

  beforeDestroy: (criteria, cb) ->
    sails.models.user
      .find criteria
      .populate 'subordinates'
      .then (users) ->
        Promise.map users, (user) ->
          Promise.map user.subordinates, (subordinate) ->
            subordinate.supervisor = null
            sails.models.user
              .update {id: subordinate.id}, subordinate
              .then Promise.resolve, Promise.reject
      .then ->
        cb()
      .catch cb

  updateCreate: (value) ->
    cond = email: value.email
    @findOne cond
      .then (user) =>
        if user?
          @update cond, _.pick(value, 'email', 'name', 'organization', 'title', 'phone', 'supervisor')
        else
          @create value
      .then =>
        @findOne cond
          .populateAll()
