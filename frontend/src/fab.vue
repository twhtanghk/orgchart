<template>
  <fab 
    bg-color='#007bff'
    :actions='actions'
    @upload='upload'
    @create='create'
    @update='update'
    @destroy='destroy'
    @expand='expand'
    @collapse='collapse'>
    <template slot='icon' slot-scope='{action}' v-if='action.tooltip == "VCard Import"'>
      <upload :action='action' />
    </template>
  </fab>
</template>

<script lang='coffee'>
module.exports =
  components:
    fab: require('vue-fab').default
    upload: require('vue-fab/src/upload').default
  props:
    eventBus:
      type: Object
      default: ->
        require('vue.oauth2/src/eventBus').default
  data: ->
    actions:
      [
        { name: 'upload', tooltip: 'VCard Import', icon: 'file_upload' }
        { name: 'create', tooltip: 'Create', icon: 'person_add' }
        { name: 'update', tooltip: 'Update', icon: 'edit' }
        { name: 'destroy', tooltip: 'Delete', icon: 'delete' }
        { name: 'expand', tooltip: 'Expand All', icon: 'add_box' }
        { name: 'collapse', tooltip: 'Collapse All', icon: 'indeterminate_check_box' }
      ]
  methods:
    upload: (files) ->
      @eventBus.$emit 'tree.upload', files
    create: ->
      @eventBus.$emit 'tree.create'
    update: ->
      @eventBus.$emit 'tree.update'
    destroy: ->
      @eventBus.$emit 'tree.destroy'
    expand: ->
      @eventBus.$emit 'tree.expand'
    collapse: ->
      @eventBus.$emit 'tree.collapse'
</script>
