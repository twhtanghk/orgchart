env = require './config.json'
React = require 'react'
E = require 'react-script'
rest = require './model.coffee'
Tree = require 'rc-tree'
Dialog = require 'rc-dialog'
update = require 'react-addons-update'

class Users extends React.Component
  @defaultProps:
    showLine: true
    draggable: true
    loadData: (node) ->
      @getUser node.props.email
    onDrop: (opts) ->
      oldSup = opts.dragNode.props.supervisor
      oldSup = oldSup.email || oldSup
      newSup = opts.node.props.email
      if oldSup == newSup
        return
      @putUser email: opts.dragNode.props.email, supervisor: opts.node.props.email

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
    else
      state || initState

actionCreator = (dispatch) ->
  getUsers: ->
    dispatch type: 'users.get'
  getUser: (email) ->
    dispatch type: 'user.get', email: email
  putUser: (email, supervisor) ->
    dispatch type: 'user.put', {email: email}, {supervisor: supervisor}
      
module.exports =
  component: Users
  state: initState
  reducer: reducer
  actionCreator: actionCreator
