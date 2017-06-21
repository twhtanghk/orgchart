require '../css/index.css'
React = require 'react'
E = require 'react-script'
rest = require './model.coffee'
Tree = require 'rc-tree'
update = require 'react-addons-update'
Promise = require 'bluebird'
_ = require 'lodash'
FloatingActionButton = require('material-ui/FloatingActionButton').default
AddIcon = require('material-ui/svg-icons/content/add').default
DeleteIcon = require('material-ui/svg-icons/action/delete').default
FlatButton = require('material-ui/FlatButton').default
TextField = require('material-ui/TextField').default
Dialog = require('material-ui/Dialog').default

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
           
class UserAdd extends React.Component
  state:
    email: ''

  add: =>
    @props.close()
    @props.addUser @state.email

  render: ->
    E Dialog,
      title: 'Create User'
      open: @props.open
      actions: [
        (
          E FlatButton,
            label: 'Cancel'
            default: true
            onTouchTap: @props.close
        )
        (
          E FlatButton,
            label: 'Create'
            primary: true
            onTouchTap: @add
        )
      ],
      E TextField,
        hintText: 'user@abc.com'
        onChange: (event, newValue) =>
          @setState email: newValue

class Users extends React.Component
  state:
    open: false
    checkedKeys: 
      checked: []

  @defaultProps:
    showLine: true
    draggable: true
    checkable: true
    checkStrictly: true
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

  onCheck: (checkedKeys) =>
    @setState checkedKeys: checkedKeys

  openAdd: =>
    @setState open: true

  closeAdd: =>
    @setState open: false

  del: =>
    @state.checkedKeys.checked.map (user) =>
      @props.delUser user

  render: ->
    node = (user) ->
      props = Object.assign {key: user.email, title: user.email}, user
      E Tree.TreeNode, props, user.subordinates?.map node
    E 'div',
      E UserAdd, 
        addUser: @props.addUser
        open: @state.open
        close: @closeAdd
      E Tree, 
        Object.assign(onCheck: @onCheck, @props),
        @props.users.results?.map node
      E FloatingActionButton, 
        onTouchTap: @del
        secondary: true
        className: 'fab delete',
        E DeleteIcon
      E FloatingActionButton, 
        onTouchTap: @openAdd
        secondary: true
        className: 'fab add',
        E AddIcon

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
    when 'user.del.ok'
      user: action.data
      users: state.users
    else
      state || initState

actionCreator = (dispatch) ->
  addUser: (email) ->
    dispatch
      type: 'user.post'
      email: email
  getUsers: ->
    dispatch type: 'users.get'
  getUser: (email) ->
    dispatch 
      type: 'user.get'
      email: email
    Promise.resolve()
  putUser: (email, supervisor) ->
    dispatch
      type: 'user.put'
      email: email
      supervisor: supervisor
  delUser: (email) ->
    dispatch 
      type: 'user.del'
      email: email
      
module.exports =
  component: Users
  state: initState
  reducer: reducer
  actionCreator: actionCreator
  util:
    find: find
    merge: merge
