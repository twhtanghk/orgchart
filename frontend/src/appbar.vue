<template>
  <mu-appbar title='Organization Chart' titleClass='left'>
    <mu-icon-button icon='menu' slot='left' />
    <mu-text-field icon='search' class='appbar-search-field' @change='change' slot='right'/>
  </mu-appbar>
</template>

<script lang='coffee'>
Vue = require('vue').default
Vue.use require('muse-ui').default

module.exports =
  props:
    eventBus:
      type: Object
      default: ->
        require('vue.oauth2/src/eventBus').default
  methods:
    change: (event, value) ->
      @eventBus.$emit 'tree.search', value
</script>

<style>
@import url('~muse-ui/dist/muse-ui.css');
@import url('~muse-ui/dist/theme-light.css');

.mu-appbar {
  position: fixed;
}

.mu-text-field {
  background-color: white;
  border-radius: 5px;
  margin-bottom: 0;
}
</style>
