_ = require 'lodash'
path = require 'path'
webpack = require 'webpack'
PolyfillInjectorPlugin = require 'webpack-polyfill-injector'

module.exports =
  entry:
    index: ['babel-polyfill', './www/js/index.coffee']
    callback: './www/js/callback.coffee'
  output:
    path: path.join __dirname, 'www/js'
    filename: "[name].js"
  plugins: [
    new webpack.EnvironmentPlugin(
      _.pick(process.env, 'AUTHURL', 'CLIENT_ID', 'SCOPE'), 
    )
    new PolyfillInjectorPlugin(
      polyfills: [
        'Object.assign'
      ]
      service: true
    )
  ]
  module:
    loaders: [
      { test: /\.coffee$/, use: [ 'coffee-loader' ] }
      { test: /\.css$/, use: ['style-loader', 'css-loader'] }
    ]
  devtool: "#source-map"
