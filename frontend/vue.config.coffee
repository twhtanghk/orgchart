webpack = require 'webpack'

module.exports =
  baseUrl: './'
  outputDir: '../backend/dist'
  configureWebpack: (config) ->
    config.node.setImmediate = true
    config.plugins.push new webpack.EnvironmentPlugin [
      'CLIENT_ID'
      'AUTH_URL'
    ]
    config.module.rules.push
      test: /\.coffee$/
      use: [ 'coffee-loader' ]
    return
