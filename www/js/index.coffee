_ = require 'lodash'
require './css'
redux = require 'redux'
thunk = require('redux-thunk').default
React = require 'react'
ReactDOM = require 'react-dom'
{Provider, connect} = require 'react-redux'
view = require './view.coffee'
rest = require './model.coffee'
reducers = redux.combineReducers rest.reducers

createStore = redux.applyMiddleware(thunk)(redux.createStore)
store = createStore reducers, {}, window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()

mapStateToProps = (state) ->
  users: state.users
Users = connect(mapStateToProps)(view.Users)
tree = React.createElement Users, 
  showLine: true
  loadData: (node) ->
    store.dispatch rest.actions.user.get _.pick node.props, 'email'
elem = React.createElement Provider, store: store, tree
ReactDOM.render elem, document.getElementById 'root'
