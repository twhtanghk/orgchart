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
      value-field-name='email'
      children-field-name='subordinates'
      :draggable='true'
      @item-toggle='toggleUser'
      @item-drop='updateSupervisor'>
      <template slot-scope='_'>
        <template v-if='!_.model.editing'>
          <i :class="_.vm.themeIconClasses" role="presentation"></i>
          <span>
            {{_.model.organization}}/{{_.model.title}}
          </span>
          <span>
            {{_.model.name.given}} {{_.model.name.family}}
          </span>
          <a :href='"mailto:" + _.model.email'>
            {{_.model.email}}
          </a>
          <a :href='"tel:" + _.model.phone[0].value' v-if='_.model.phone'>
            {{_.model.phone[0].value}}
          </a>
        </template>
        <template v-if='_.model.editing'>
          <b-form-input
            v-model='_.model.organization'
            type='text'
            placeholder='Organization'
            required />
          <b-form-input
            v-model='_.model.title'
            type='text'
            placeholder='Title'
            required />
          <b-form-input
            v-model='_.model.name.given'
            type='text'
            placeholder='Given Name'
            required />
          <b-form-input
            v-model='_.model.name.family'
            type='text'
            placeholder='Surname'
            required />
          <b-form-input
            v-model='_.model.email'
            type='text'
            placeholder='Email'
            required />
          <b-form-input
            v-model='_.model.phone'
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
      @users[0].phone = [
        type: 'Office'
        value: @users[0].phone
      ]
      _.extend @users[0], await @$refs.user.create data: @users[0]
      @users[0].editing = false
    cancel: ->
      @users.shift()
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
