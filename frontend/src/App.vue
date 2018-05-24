<template>
  <div id="app">
    <appbar />
    <tree />
    <fab />
  </div>
</template>

<script lang='coffee'>
module.exports =
  components:
    appbar: require('./appbar').default
    fab: require('./fab').default
    tree: require('./tree').default
</script>

<style>
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
</style>
