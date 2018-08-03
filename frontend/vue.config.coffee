_ = require 'lodash'
webpack = require 'webpack'

module.exports =
  baseUrl: './'
  outputDir: '../backend/dist'
  lintOnSave: false
  transpileDependencies: [
    /multipipe/
  ]
  configureWebpack: (config) ->
    config.output.publicPath = ''
    config.node.setImmediate = true
    config.plugins.push new webpack.EnvironmentPlugin [
      'CLIENT_ID'
      'AUTH_URL'
    ]
    config.module.rules
      .push
        test: /\.coffee$/
        use: [ 'babel-loader', 'coffee-loader' ]
    _.extend config.optimization, minimize: false
    config.entry.app.unshift 'whatwg-fetch', 'url-search-params-polyfill'
    return
