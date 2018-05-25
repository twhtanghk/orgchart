<template>
  <authForm
    :eventBus='eventBus'
    :oauth2='oauth2' />
</template>

<script lang='coffee'>
_ = require 'lodash'
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default

module.exports =
  extends: require('vue.model/src/model').default
  methods:
    format: (data) ->
      _.extend data,
        icon: 'fa fa-user icon-state-default'
        subordinates: data.subordinates?.map @format
        opened: false
    reload: (user) ->
      user.subordinates ?= []
      user.subordinates.splice 0, user.subordinates.length
      {next} = @getSubordinates user.id
      while true
        {done, value} = await next()
        break if done
        for i in value
          user.subordinates.push i
    iterSupervisor: (user) ->
      if 'supervisor' of user and user.supervisor?
        yield from @iterSupervisor user.supervisor
      yield user
    getSupervisor: (user) ->
      if 'supervisor' of user and user.supervisor?
        user.supervisor = await @read data: id: user.supervisor.id
        user.supervisor = await @getSupervisor user.supervisor
      user    
    getSubordinates: (supervisor = null) ->
      gen = @listAll
        data:
          supervisor: supervisor
          sort: [
            organization: 'ASC'
          ]
      gen()
    dropUser: ({subordinate, supervisor}) ->
      await @post
        data:
          id: subordinate.id
          email: subordinate.email
          supervisor: supervisor.id
  props:
    users:
      type: Array
      required: true
    eventBus:
      type: Object
      default: ->
        require('vue.oauth2/src/eventBus').default
  data: ->
    oauth2:
      url: process.env.AUTH_URL
      client: process.env.CLIENT_ID
      scope: 'User'
      response_type: 'token'
  mounted: ->
    {next} = @getSubordinates()
    while true
      {done, value} = await next()
      break if done
      for i in value
        @users.push i
</script>
