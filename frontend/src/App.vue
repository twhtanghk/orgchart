<template>
  <div id="app">
    <fab 
      bg-color='#007bff'
      :actions='actions'
      @upload='upload'
      @create='create'
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
      idAttribute='email'
      baseUrl='http://172.24.0.3:1337/api/user' />
    <tree 
      ref='tree'
      multiple
      :data='users'
      :showCheckbox='true'
      value-field-name='email'
      children-field-name='subordinates'
      :draggable='true'
      @item-toggle='toggleUser'
      @item-drop='updateSupervisor'>
      <template slot-scope='{model, vm}'>
        <template v-if='!model.editing'>
          <i :class="vm.themeIconClasses" role="presentation"></i>
          <span v-if='model.organization || model.title'>
            {{model.organization}}/{{model.title}}
          </span>
          <span v-if='model.name'>
            {{model.name.given}} {{model.name.family}}
          </span>
          <a :href='"mailto:" + model.email'>
            {{model.email}}
          </a>
          <a :href='"tel:" + model.phone.office' v-if='model.phone'>
            {{model.phone.office}}
          </a>
        </template>
        <template v-if='model.editing'>
          <b-form-input
            v-model='model.organization'
            type='text'
            placeholder='Organization'
            required />
          <b-form-input
            v-model='model.title'
            type='text'
            placeholder='Title'
            required />
          <b-form-input
            v-model='model.name.given'
            type='text'
            placeholder='Given Name'
            required />
          <b-form-input
            v-model='model.name.family'
            type='text'
            placeholder='Surname'
            required />
          <b-form-input
            v-model='model.email'
            type='text'
            placeholder='Email'
            required />
          <b-form-input
            v-model='model.phone'
            type='tel'
            placeholder='Phone No'
            required />
          <b-button 
            @click.stop='save'
            size='sm'
            variant='primary'>
            Add
          </b-button>
          <b-button
            @click.stop='cancel'
            size='sm'
            variant='secondary'>
            Cancel
          </b-button>
        </template>
      </template>
    </tree>
  </div>
</template>

<script lang='coffee'>
stream = require 'stream'
FileReadStream = require 'filestream/read'
Parser = require('csv').parse
_ = require 'lodash'
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default

module.exports =
  components:
    upload: require('vue-fab/src/upload').default
    fab: require('vue-fab').default
    tree:
      extends: require('vue-jstree').default
    model:
      extends: require('vue.model/src/model').default
      methods:
        format: (data) ->
          _.extend data,
            icon: 'fa fa-user icon-state-default'
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
              email: subordinate
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
        { name: 'upload', tooltip: 'Upload', icon: 'file_upload' }
        { name: 'create', tooltip: 'Create', icon: 'person_add' }
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
      _.extend item, await @$refs.user.get data: email: item.email
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
    upload: (files) ->
      model = @$refs.user

      class CSV extends stream.Writable
        _write: (chunk, encoding, cb) ->
          [ input, title, org ] = /([ a-zA-Z0-9]*)(\(*.*)/.exec chunk['Job Title'].trim()
          user =
            email: chunk['Internet Address']
            name:
              given: chunk['First Name']
              family: chunk['Last Name']
            organization: org
            title: title
            phone:
              office: chunk['Business Phone']
          model
            .update data: user
            .then ->
              cb()
            .catch (err) ->
              console.log
                data: user
                err: err
              cb()

      for file in files
        new FileReadStream file
          .on 'error', console.error
          .pipe new Parser columns: true
          .on 'error', console.error
          .pipe new CSV objectMode: true
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
    save: ->
      @users[0].phone =
        office: @users[0].phone
      _.extend @users[0], await @$refs.user.create data: @users[0]
      @users[0].editing = false
    cancel: ->
      @users.shift()
    destroy: ->
      @selected().map ({list, key, node}) =>
        await @$refs.user.delete data: email: node.email
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
