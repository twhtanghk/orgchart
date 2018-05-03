<template>
  <div id="app">
    <fab 
      bg-color='#007bff'
      :actions='actions'
      @create='create'
      @destroy='destroy'
      @expand='expand'
      @collapse='collapse' />
    <authForm
      :eventBus='eventBus'
      :oauth2='oauth2' />
    <model
      ref='user'
      :eventBus='eventBus'
      baseUrl='http://172.24.0.3:1337/api/user' />
    <tree 
      ref='tree'
      multiple
      :data='users'
      :showCheckbox='true'
      text-field-name='display'
      value-field-name='email'
      children-field-name='subordinates'
      :draggable='true'
      @item-toggle='toggleUser'
      @item-drop='updateSupervisor' />
  </div>
</template>

<script lang='coffee'>
_ = require 'lodash'
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default

module.exports =
  components:
    fab: require('vue-fab').default
    tree:
      extends: require('vue-jstree').default
    model:
      extends: require('vue.model/src/model').default
      methods:
        ou: (data) ->
          if data.organization? or data.title?
            "#{data.organization || ''}/#{data.title || ''}"
          else
            ''
        fullname: (data) ->
          {given, family} = data.name
          if given? or family?
            "#{given || ''} #{family || ''}"
          else
            ''
        display: (data) ->
          "#{@ou data} #{@fullname data} #{data.email}"
        format: (data) ->
          _.extend data,
            icon: 'fa fa-user icon-state-default'
            display: "#{@display data}"
            subordinates: data.subordinates?.map @format
        getUsers: (supervisor = null) ->
          gen = @listAll
            data:
              supervisor: supervisor
              sort:
                organization: 1
          gen()
        dropUser: ({subordinate, supervisor}) ->
          await @update 
            data:
              id: subordinate
              supervisor: supervisor
  data: ->
    searchword: ''
    users: []
    eventBus: require('vue.oauth2/src/eventBus').default
    oauth2:
      url: process.env.AUTH_URL
      client: process.env.CLIENT_ID
      scope: 'User'
      response_type: 'token'
    actions:
      [
        { name: 'create', tooltip: 'Create', icon: 'add' }
        { name: 'destroy', tooltip: 'Delete', icon: 'delete' }
        { name: 'expand', tooltip: 'Expand All', icon: 'add_box' }
        { name: 'collapse', tooltip: 'Collapse All', icon: 'indeterminate_check_box' }
      ]
  methods:
    updateSupervisor: (node, item, draggedItem, e) ->
      data =
        supervisor: item.email
        subordinate: draggedItem.email
      await @$refs.user.dropUser data
      _.extend item, await @$refs.user.get data: id: item.email
    toggleUser: (node, item, e) ->
      if item.opened
        item.subordinates.splice 0, item.subordinates.length
        {next} = @$refs.user.getUsers item.email
        while true
          {done, value} = await next item.subordinates.length
          break if done
          for i in value
            item.subordinates.push i
    dfs: (nodes = @users) ->
      for index, user of nodes
        yield {list: nodes, key: index, node: user}
        if user.subordinates?
          yield from @dfs user.subordinates
    selected: (nodes = @users) ->
      ret = []
      for {list, key, node} from @dfs nodes
        if node.selected
          ret.push {list, key, node}
      ret
    create: ->
      console.log 'collapse'
    destroy: ->
      @selected().map ({list, key, node}) =>
        await @$refs.user.delete data: id: node.email
        index = list.findIndex (user) ->
          user.email == node.email
        list.splice index, 1
    expand: (nodes = @users) ->
      for {list, key, node} from @dfs nodes
        node.opened = true
        await @toggleUser null, node
    collapse: (nodes = @users) ->
      for {list, key, node} from @dfs nodes
        node.opened = false
  mounted: ->
    {next} = @$refs.user.getUsers()
    while true
      {done, value} = await next @users.length
      break if done
      for i in value
        @users.push i
</script>

<style>
@import 'https://use.fontawesome.com/releases/v5.0.9/css/all.css';
@import 'https://fonts.googleapis.com/icon?family=Material+Icons';
@import 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css';

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
