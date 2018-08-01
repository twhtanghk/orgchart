<template>
  <div id="app">
    <search />
    <tree />
    <fab />
  </div>
</template>

<script lang='coffee'>
export default
  components:
    search: require('./search').default
    fab: require('./fab').default
    tree: require('./tree').default
</script>

<style>
@import 'https://use.fontawesome.com/releases/v5.0.9/css/all.css';
@import '../node_modules/material-icons/iconfont/material-icons.css';
@import 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css';

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
