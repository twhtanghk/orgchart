webpack = require 'webpack'

module.exports =
  baseUrl: './'
  configureWebpack: (config) ->
    if process.env.NODE_ENV == 'production'
      config.output.path = require('path').resolve __dirname, '../backend/dist'
    config.node.setImmediate = true
    config.plugins.push new webpack.EnvironmentPlugin [
      'CLIENT_ID'
      'AUTH_URL'
    ]
    return
