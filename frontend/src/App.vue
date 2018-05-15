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
    <tree 
      ref='tree'
      multiple
      :data='users'
      :showCheckbox='true'
      value-field-name='email'
      children-field-name='subordinates'
      :draggable='true'
      @item-drag-start='dragStart'
      @item-drag-end='dragEnd'
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
            v-model='model.phone.office'
            type='tel'
            placeholder='Phone No'
            required />
          <b-button 
            @click.stop='save(model)'
            size='sm'
            variant='primary'>
            Save
          </b-button>
          <b-button
            @click.stop='cancel(model)'
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
    tree:
      extends: require('vue-jstree/src/tree').default
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
    updateSupervisor: (node, item, draggedItem, e) ->
      data =
        supervisor: item
        subordinate: draggedItem
      await @$refs.user.dropUser data
      await @$refs.user.reload data.supervisor
    dragStart: (node, item, e) ->
      for {list, key, node} from @dfs item.subordinates
        node.dropDisabled = true
    dragEnd: (node, item, e) ->
      for {list, key, node} from @dfs item.subordinates
        delete node.dropDisabled
    toggleUser: (node, item, e) ->
      if item.opened
        await @$refs.user.reload item
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
