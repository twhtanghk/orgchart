<template>
  <div id="app">
    <authForm :eventBus='eventBus' :oauth2='oauth2' />
    <model ref='user' :eventBus='eventBus' baseUrl='http://172.24.0.3:1337/api/user' />
    <tree 
      :data='users'
      :showCheckbox='true'
      :text-field-name='"email"'
      :value-field-name='"email"'
      :draggable='true'
      :on-item-drop='drop'
    />
  </div>
</template>

<script lang='coffee'>
Vue = require('vue').default
Vue.use require('vue.oauth2/src/plugin').default
Vue.use require('vue.model/src/plugin').default
Vue.use require('vue-async-computed')

module.exports =
  components:
    tree: require('vue-jstree').default
  data: ->
    searchword: ''
    users: []
    eventBus: require('vue.oauth2/src/eventBus').default
    oauth2:
      url: process.env.AUTH_URL
      client: process.env.CLIENT_ID
      scope: 'User'
      response_type: 'token'
  methods:
    drop: ->
      console.log arguments
  mounted: ->
    do =>
      gen = @$refs.user?.listAll
        data:
          supervisor: null
          sort:
            email: 1
      if gen?
        {next} = gen()
        while true
          {done, value} = await next @users.length
          break if done
          for i in value
            @users.push i
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
