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
      user.subordinates.splice 0, user.subordinates.length
      {next} = @getUsers user.id
      while true
        {done, value} = await next user.subordinates.length
        break if done
        for i in value
          user.subordinates.push i
    getUsers: (supervisor = null) ->
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
    {next} = @getUsers()
    while true
      {done, value} = await next @users.length
      break if done
      for i in value
        @users.push i
</script>
