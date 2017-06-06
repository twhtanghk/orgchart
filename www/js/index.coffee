_ = require 'lodash'
require './css'
redux = require 'redux'
thunk = require('redux-thunk').default
React = require 'react'
E = require 'react-script'
ReactDOM = require 'react-dom'
{Provider, connect} = require 'react-redux'
view = require './view.coffee'
rest = require './model.coffee'
update = require 'react-addons-update'
middleware = require './middleware.coffee'
reducer = require './reducer.coffee'

reducers = redux.combineReducers Object.assign {}, rest.reducers, reducer

createStore = redux.applyMiddleware(thunk, middleware)(redux.createStore)
initState =
  users: {}
  user: {}
  auth:
    visible: false
    token: null
store = createStore reducers, initState, window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()

mapDispatchToProps = (dispatch) ->
  login: ->
    dispatch type: 'login'
  loginReject: (err) ->
    dispatch type: 'loginReject', error: err
  loginResolve: (token) ->
    dispatch type: 'loginResolve', token: token
  logout: ->
    dispatch type: 'logout'
  getUsers: ->
    dispatch rest.actions.users.sync()
  getUser: (email) ->
    dispatch rest.actions.user.get email: email
  putUser: (data) ->
    dispatch rest.actions.user.put {email: data.email}, {body: JSON.stringify supervisor: data.supervisor}

Auth = connect(((state) -> state.auth), mapDispatchToProps)(view.Auth)
Users = connect(((state) -> users: state.users), mapDispatchToProps)(view.Users)

elem =
  E Provider, store: store,
    E 'div', {},
      E Auth, require './config.json'
      E Users

ReactDOM.render elem, document.getElementById 'root'
