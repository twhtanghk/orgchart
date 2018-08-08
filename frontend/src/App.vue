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

<style lang='scss'>
$material-icons-font-path: '~material-icons/iconfont/';

@import '~material-icons/iconfont/material-icons.scss';
@import url('https://use.fontawesome.com/releases/v5.0.9/css/all.css');
@import url('https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.5.2/animate.min.css');

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
