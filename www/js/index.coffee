_ = require 'lodash'
require './css'
{createStore, combineReducers, applyMiddleware} = require 'redux'
React = require 'react'
E = require 'react-script'
ReactDOM = require 'react-dom'
{Provider, connect} = require 'react-redux'
rest = require './model.coffee'
update = require 'react-addons-update'
createSagaMiddleware = require('redux-saga').default
Auth = require 'rc-oauth2'
User = require './user.coffee'

initState =
  auth: Auth.state
  data: User.state

reducer = combineReducers
  auth: Auth.reducer
  data: User.reducer

composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose

sagaMiddleware = createSagaMiddleware()

store = createStore reducer, initState, composeEnhancers applyMiddleware sagaMiddleware

sagaMiddleware.run require './saga.coffee'

Auth = connect(((state) -> state.auth), Auth.actionCreator)(Auth.component)
Users = connect(((state) -> state.data), User.actionCreator)(User.component)

elem =
  E Provider, store: store,
    E 'div', {},
      E Auth, require './config.json'
      E Users

ReactDOM.render elem, document.getElementById 'root'
