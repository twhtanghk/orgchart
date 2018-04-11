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
      :text-field-name='"display"'
      :value-field-name='"email"'
      :draggable='true'
      :async='load' />
  </div>
</template>

<script lang='coffee'>
_ = require 'lodash'
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default
tree = require('vue-jstree').default

module.exports =
  components:
    fab: require('vue-fab').default
    tree:
      extends: tree
      methods:
        onItemDrop: (e, oriNode, oriItem) ->
          supervisor = oriNode.model.email
          subordinate = @draggedItem.item.email
          if supervisor == subordinate
            return
          node = @draggedItem
          {parentItem, index} = @draggedItem
          @$parent.$refs.user
            .update subordinate,
              data:
                supervisor: supervisor
            .then =>
              parentItem.splice index, 1
              oriNode.model.addChild node
              oriNode.model.openChildren()
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
          data.subordinates = data.subordinates?.map @format
          _.extend data,
            icon: 'fa fa-user icon-state-default'
            display: "#{@display data}"
            children: data.subordinates
            parent: data.supervisor
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
    load: (oriNode, cb) ->
      ret = []
      gen = @$refs.user?.listAll
        data:
          supervisor: if oriNode.model? then oriNode.model.email else null
          sort:
            organization: 1
      if gen?
        {next} = gen()
        while true
          {done, value} = await next ret.length
          break if done
          ret = ret.concat value
      cb ret
    dfs: (nodes, func) ->
      nodes.map (user, key, list) =>
        if user.children?
          @dfs user.children, func
        func user, key, list
    selected: (nodes = @users) ->
      ret = []
      @dfs nodes, (user, key, list) ->
        if user.selected
          ret.push
            list: list
            key: key
            node: user
      ret
    create: ->
      console.log 'collapse'
    destroy: ->
      @selected().map ({list, key, node}) =>
        @$refs.user
          .delete node.email
          .then ->
            list.splice key, 1
    expand: (nodes = @users) ->
      nodes.map (user) =>
        user.openChildren()
        if user.children?
          @expand user.children
    collapse: (nodes = @users) ->
      nodes.map (user) =>
        user.opened = false
        if user.subordinates?
          @collapse user.subordinates
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
