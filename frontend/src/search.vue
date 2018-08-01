<template>
  <mu-text-field icon='search' @change='change'/>
</template>

<script lang='coffee'>
Vue = require('vue').default
Vue.use require('muse-ui').default

export default
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

.mu-text-field {
  border: solid rgb(0, 123, 255) 2px;
  border-radius: 5px;
  right: 5vw;
  top: 2vh;
  z-index: 999;
  position: fixed;
}
</style>
