env = require './config.json'
React = require 'react'
E = require 'react-script'
rest = require './model.coffee'
Tree = require 'rc-tree'
Dialog = require 'rc-dialog'
update = require 'react-addons-update'
Promise = require 'bluebird'
_ = require 'lodash'

find = (user, users) ->
  cb = (initVal, node) ->
    if initVal?
      initVal
    else if node.email == user.email
      node
    else
      _.reduce node.subordinates, cb, initVal
  _.reduce users.results, cb, null

merge = (user, users) ->
  cb = (node) ->
    if node.email == user.email
      update node, $merge: user
    else
      node.subordinates = _.map node.subordinates, cb
      node
  update users, 
    results: 
      $merge: _.map users.results, cb
           
class Users extends React.Component
  @defaultProps:
    showLine: true
    draggable: true
    loadData: (node) ->
      @getUser node.props.email
    onDrop: (opts) ->
      oldSup = opts.dragNode.props.supervisor
      oldSup = oldSup?.email || oldSup
      newSup = opts.node.props.email
      if oldSup == newSup
        return
      @putUser opts.dragNode.props.email, opts.node.props.email

  componentDidMount: ->
    @props.getUsers()

  render: ->
    node = (user) ->
      props = Object.assign {key: user.email, title: user.email}, user
      E Tree.TreeNode, props, user.subordinates?.map node
    E Tree, @props, @props.users.results?.map node

initState =
  users: 
    count: 0
    result: []
  user: {}

reducer = (state, action) ->
  switch action.type
    when 'users.get.ok'
      user: state.user
      users: action.data
    when 'user.get.ok'
      user: action.data
      users: merge action.data, state.users
    when 'user.put.ok'
      user: action.data
      users: merge action.data, state.users
    else
      state || initState

actionCreator = (dispatch) ->
  getUsers: ->
    dispatch type: 'users.get'
  getUser: (email) ->
    dispatch type: 'user.get', email: email
    Promise.resolve()
  putUser: (email, supervisor) ->
    dispatch Object.assign type: 'user.put', 
      email: email
      supervisor: supervisor
      
module.exports =
  component: Users
  state: initState
  reducer: reducer
  actionCreator: actionCreator
  util:
    find: find
    merge: merge
