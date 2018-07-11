webpack = require 'webpack'

module.exports =
  baseUrl: './'
  outputDir: '../backend/dist'
  configureWebpack: (config) ->
    config.output.publicPath = ''
    config.node.setImmediate = true
    config.plugins.push new webpack.EnvironmentPlugin [
      'CLIENT_ID'
      'AUTH_URL'
    ]
    config.module.rules.push
      test: /\.coffee$/
      use: [ 'coffee-loader' ]
    config.optimization.minimize = false
    return
