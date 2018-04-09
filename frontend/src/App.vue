<template>
  <div id="app">
    <authForm :eventBus='eventBus' :oauth2='oauth2' />
    <model ref='user' :eventBus='eventBus' baseUrl='http://172.24.0.3:8080/api/user' />
  </div>
</template>

<script lang='coffee'>
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default
Vue.use require('vue.model/src/plugin').default
Vue.use require('vue-async-computed')
eventBus require('vue.oauth2/src/eventBus').default

module.exports =
  data: ->
    searchword: ''
    treeData: []
  mounted: ->
    @$refs.user.list()
      .then (res) ->
        treeData = res
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
