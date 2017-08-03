_ = require 'lodash'
path = require 'path'
webpack = require 'webpack'

babelLoader =
  loader: 'babel-loader'
  query:
    plugins: [ 
      [
        'transform-runtime'
        {
          helpers: false
          polyfill: true
          regenerator: true
          moduleName: 'babel-runtime'
        }
      ]
    ]
    presets: [
      'es2015'
      'stage-2'
    ]

module.exports =
  entry:
    index: [
      'whatwg-fetch'
      'babel-polyfill'
      './www/js/index.coffee'
    ]
    callback: './www/js/callback.coffee'
  output:
    path: path.join __dirname, 'www/js'
    filename: "[name].js"
  plugins: [
    new webpack.EnvironmentPlugin(
      _.pick(process.env, 'PROFILEURL', 'AUTHURL', 'CLIENT_ID', 'SCOPE')
    )
  ]
  module:
    loaders: [
      { 
        test: /\.scss$/
        use: [
          'style-loader'
          'css-loader'
          'sass-loader'
        ] 
      }
      { 
        test: /\.css$/
        use: [
          'style-loader'
          'css-loader'
        ] 
      }
      { 
        test: /saga\-model/
        use: [
          babelLoader
        ]
      }
      { 
        test: /\.coffee$/
        exclude: /node_modules/
        use: [
          babelLoader
          {
            loader: 'coffee-loader'
            options:
              sourceMap: true
          }
        ]
      }
    ]
  devtool: "#source-map"
