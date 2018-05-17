<template>
  <div id="app">
    <fab 
      bg-color='#007bff'
      :actions='actions'
      @upload='upload'
      @create='create'
      @update='update'
      @destroy='destroy'
      @expand='expand'
      @collapse='collapse'>
      <template slot='icon' slot-scope='{action}' v-if='action.tooltip == "Upload"'>
        <upload :action='action' />
      </template>
    </fab>
    <authForm
      :eventBus='eventBus'
      :oauth2='oauth2' />
    <model
      ref='user'
      :eventBus='eventBus'
      baseUrl='http://172.24.0.3:1337/api/user' />
    <tree ref='tree' :data='users' :remote='$refs.user' />
  </div>
</template>

<script lang='coffee'>
{Writable} = require 'stream'
FileReadStream = require 'filestream/read'
Parser = require('csv').parse
_ = require 'lodash'
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default

module.exports =
  components:
    upload: require('vue-fab/src/upload').default
    fab: require('vue-fab').default
    tree: require('./tree').default
    model:
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
        { name: 'upload', tooltip: 'Upload', icon: 'file_upload' }
        { name: 'create', tooltip: 'Create', icon: 'person_add' }
        { name: 'update', tooltip: 'Update', icon: 'edit' }
        { name: 'destroy', tooltip: 'Delete', icon: 'delete' }
        { name: 'expand', tooltip: 'Expand All', icon: 'add_box' }
        { name: 'collapse', tooltip: 'Collapse All', icon: 'indeterminate_check_box' }
      ]
  methods:
    upload: (files) ->
      model = @$refs.user
      class Upload extends Writable
        _write: (chunk, encoding, cb) ->
          chunk.phone = office: chunk.tel
          if chunk.email?
            await model.post data: chunk
          else
            console.error "skip #{JSON.stringify chunk}"
          cb()

      vcard = require('./vcard.coffee').default
      for file in files
        new FileReadStream file
          .pipe vcard
          .on 'error', console.error
          .pipe new Upload objectMode: true
          .on 'error', console.error
    create: ->
      @users.unshift @$refs.user.format
        email: ''
        name:
          given: ''
          family: ''
        organization: ''
        title: ''
        phone: ''
        editing: true
      window.scrollTo 0, 0
    update: ->
      @selected().map ({list, key, node}) ->
        node.editing = true
    save: (model) ->
      _.extend model, await @$refs.user.create data: model
      model.editing = false
    cancel: (model) ->
      model.editing = false
    destroy: ->
      @selected().map ({list, key, node}) =>
        await @$refs.user.delete data: id: node.id
        index = list.findIndex (user) ->
          user.id == node.id
        list.splice index, 1
    expand: ->
      @$refs.tree.expand()
    collapse: ->
      @$refs.tree.collapse()
  mounted: ->
    {next} = @$refs.user.getUsers()
    while true
      {done, value} = await next @users.length
      break if done
      for i in value
        @users.push i
</script>

<style scoped>
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

input {
  display: inline-block;
  padding: 0;
}

input[placeholder=Organization] {
  width: 12ch;
}

input[placeholder=Title] {
  width: 6ch;
}

input[placeholder='Given Name'] {
  width: 12ch;
}

input[placeholder=Surname] {
  width: 8ch;
}

input[placeholder='Email'] {
  width: 20ch;
}

input[placeholder='Phone No'] {
  width: 10ch;
}

button {
  margin-left: 2px;
}
</style>
