<template>
  <div id='tree'>
    <model 
      ref='remote'
      :users='data'
      baseUrl='api/user' />
    <tree 
      multiple
      :data='data'
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
          <span>
            {{model.givenName}} {{model.familyName}}
          </span>
          <a class='action' @click.stop :href='"mailto:" + model.email'>
            <i class='fa fa-envelope' />
          </a>
          <a class='action' @click.stop :href='"tel:" + model.phone.office' v-if='"office" in model.phone'>
            <i class='fa fa-phone' />
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
            v-model='model.givenName'
            type='text'
            placeholder='Given Name'
            required />
          <b-form-input
            v-model='model.familyName'
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
_ = require 'lodash'
{Writable} = require 'stream'
FileReadStream = require 'filestream/read'
Parser = require('csv').parse

export default
  components:
    tree: require('vue-jstree/src/tree').default
    model: require('./model').default
  props:
    eventBus:
      type: Object
      default: ->
        require('vue.oauth2/src/eventBus').default
  data: ->
    data: []
  methods:
    dragStart: (node, item, e) ->
      for {list, key, node} from @dfs item.subordinates
        node.dropDisabled = true
    dragEnd: (node, item, e) ->
      for {list, key, node} from @dfs item.subordinates
        delete node.dropDisabled
    toggleUser: (node, item, e) ->
      if item.opened
        await @$refs.remote.reload item
    dfs: (nodes = @data) ->
      for index, user of nodes
        yield {list: nodes, key: index, node: user}
        if user.subordinates?
          yield from @dfs user.subordinates
    selected: (nodes = @data) ->
      ret = []
      for {list, key, node} from @dfs nodes
        if node.selected
          ret.push {list, key, node}
      ret
    updateSupervisor: (node, item, draggedItem, e) ->
      data =
        supervisor: item
        subordinate: draggedItem
      await @$refs.remote.dropUser data
      await @$refs.remote.reload data.supervisor
    search: (value) ->
      if value == ''
        return
      cond = contains: value
      data =
        or: [
          {email: cond}
          {title: cond}
          {organization: cond}
          {givenName: cond}
          {familyName: cond}
        ]
      for await i from @$refs.remote.iterAll data: data
        user = await @$refs.remote.getSupervisor i
        list = @data
        for j from @$refs.remote.iterSupervisor user
          list
            .find (user) ->
              user.email == i.email
            ?.selected = true
          supervisor = list.find (user) ->
            user.email == j.email
          supervisor?.opened = true
          if not (supervisor.subordinates? and supervisor.subordinates.length != 30)
            await @toggleUser null, supervisor
          list = supervisor.subordinates
    upload: (files) ->
      model = @$refs.remote
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
          .pipe vcard()
          .on 'error', console.error
          .pipe new Upload objectMode: true
          .on 'error', console.error
    create: ->
      @data.unshift @$refs.remote.format
        email: ''
        givenName: ''
        familyName: ''
        organization: ''
        title: ''
        phone: ''
        editing: true
      window.scrollTo 0, 0
    update: ->
      @selected().map ({list, key, node}) ->
        node.editing = true
    save: (model) ->
      _.extend model, await @$refs.remote.create data: model
      model.editing = false
    cancel: (model) ->
      model.editing = false
    destroy: ->
      @selected().map ({list, key, node}) =>
        await @$refs.remote.delete data: id: node.id
        # remove deleted entry
        index = list.findIndex (user) ->
          user.id == node.id
        list.splice index, 1
        # append subordinates to root if any
        @data.push node.subordinates...
    expand: (nodes = @data) ->
      for {list, key, node} from @dfs nodes
        node.opened = true
        await @toggleUser null, node
    collapse: (nodes = @data) ->
      for {list, key, node} from @dfs nodes
        node.opened = false
  created: ->
    @eventBus
      .$on 'tree.search', @search
      .$on 'tree.upload', @upload
      .$on 'tree.create', @create
      .$on 'tree.update', @update
      .$on 'tree.destroy', @destroy
      .$on 'tree.expand', @expand
      .$on 'tree.collapse', @collapse
</script>

<style scoped>
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

a.action {
  padding: .3em;
}
</style>
