require 'rc-tree/assets/index.css'
require 'react-redux-toastr/lib/css/react-redux-toastr.min.css'
_ = require 'lodash'
{compose, createStore, combineReducers, applyMiddleware} = require 'redux'
React = require 'react'
E = require 'react-script'
ReactDOM = require 'react-dom'
{Provider, connect} = require 'react-redux'
rest = require './model.coffee'
update = require 'react-addons-update'
createSagaMiddleware = require('redux-saga').default
Auth = require 'rc-oauth2'
User = require './user.coffee'
Toastr = require 'react-redux-toastr'
MuiThemeProvider = require('material-ui/styles/MuiThemeProvider').default
require('react-tap-event-plugin')()

initState =
  auth: Auth.state
  data: User.state

reducer = combineReducers
  auth: Auth.reducer
  data: User.reducer
  toastr: Toastr.reducer

composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose

sagaMiddleware = createSagaMiddleware()

store = createStore reducer, initState, composeEnhancers applyMiddleware sagaMiddleware

sagaMiddleware.run require './saga.coffee'

Auth = connect(((state) -> state.auth), Auth.actionCreator)(Auth.component)
Users = connect(((state) -> state.data), User.actionCreator)(User.component)

elem =
  E Provider, store: store,
    E MuiThemeProvider,
      E 'div', 
        E Toastr.default
        E Auth,
          AUTHURL: process.env.AUTHURL
          CLIENT_ID: process.env.CLIENT_ID
          SCOPE: process.env.SCOPE
        E Users

ReactDOM.render elem, document.getElementById 'root'
