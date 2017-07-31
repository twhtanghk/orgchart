_ = require 'lodash'
require 'rc-tree/assets/index.css'
React = require 'react'
E = require 'react-script'
Tree = require('rc-tree').default
update = require 'react-addons-update'
Promise = require 'bluebird'
Avatar = require('material-ui/Avatar').default
Person = require('material-ui/svg-icons/social/person').default
Close = require('material-ui/svg-icons/navigation/close').default
Add = require('material-ui/svg-icons/content/add').default
Delete = require('material-ui/svg-icons/action/delete').default
Expand = require('material-ui/svg-icons/content/add-box').default
Collapse = require('material-ui/svg-icons/toggle/indeterminate-check-box').default
FlatButton = require('material-ui/FlatButton').default
TextField = require('material-ui/TextField').default
Dialog = require('material-ui/Dialog').default
{ SpeedDial, BubbleList, BubbleListItem } = require 'react-speed-dial'

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

class Actions extends React.Component
  render: ->
    E SpeedDial,
      hasBackdrop: false,
      E BubbleList,
        E BubbleListItem,
          primaryText: 'Add'
          rightAvatar: E Avatar, icon: E Add
          onTouchTap: @props.openAdd
        E BubbleListItem,
          primaryText: 'Delete'
          rightAvatar: E Avatar, icon: E Delete
          onTouchTap: @props.del
        E BubbleListItem,
          primaryText: 'Expand All'
          rightAvatar: E Avatar, icon: E Expand
          onTouchTap: @props.expandAll
        E BubbleListItem,
          primaryText: 'Collapse All'
          rightAvatar: E Avatar, icon: E Collapse
          onTouchTap: @props.collapseAll

class Users extends React.Component
  state:
    open: false
    checkedKeys: 
      checked: []

  @defaultProps:
    size: 17
    showIcon: false
    showLine: true
    draggable: true
    checkable: true
    checkStrictly: true
    loadData: (node) ->
      @getUser node.props.email
    onDrop: (opts) ->
      user = opts.dragNode.props.email
      oldSup = user.supervisor
      newSup = opts.node.props.email
      if oldSup == newSup
        return
      @putUser user, newSup

  componentDidMount: ->
    @props.getUsers()

  onCheck: (checkedKeys) =>
    @props.check checkedKeys

  onExpand: (expandedKeys, opts) =>
    if not opts.expanded
      cb = (accumulator, node) ->
        ret = [node.email].concat accumulator
        _.reduce node.subordinates, cb, ret
      node = opts.node.props
      @props.collapse _.reduce(node.subordinates, cb, [node.email])

  expandAll: =>
    @props.expandAll()

  collapseAll: =>
    @props.collapseAll()

  openAdd: =>
    @setState open: true

  closeAdd: =>
    @setState open: false

  del: =>
    @props.checkedKeys.checked.map (user) =>
      @props.delUser user

  node: (user) ->
    attrs = 
      icon: E Person
    if user.photoUrl? 
      attrs =
        src: "#{process.env.PROFILEURL}/#{user.photoUrl}"
        backgroundColor: 'transparent'
        style:
          verticalAlign: 'middle'
          display: 'inherit'
    title = [
      E Avatar, Object.assign(attrs,
        key: 1
        size: @props.size
      )
      E 'span',
        key: 2
        style:
          marginLeft: 5,
        user.getDisplayName()
    ]
    props = Object.assign {}, user,
      key: user.email
      title: title,
    E Tree.TreeNode, props, user.subordinates?.map (user) =>
      @node user

  render: ->
    E 'div',
      E Actions,
        openAdd: @openAdd
        del: @del
        expandAll: @expandAll
        collapseAll: @collapseAll
      E UserAdd, 
        addUser: @props.addUser
        open: @state.open
        close: @closeAdd
      E Tree, Object.assign(
        checkedKeys: @props.checkedKeys,
        expandedKeys: @props.expandedKeys,
        onExpand: @onExpand,
        onCheck: @onCheck, 
        @props),
        @props.users.map (user) =>
          @node user

{ User } = require './model.coffee'
initState =
  checkedKeys:
    checked: []
  expandedKeys: []
  users: User.users
  user: User.user

reducer = (state, action) ->
  traverse = (accumulator, user) ->
    _.reduce user.subordinates, traverse, accumulator.concat([user.email])
  switch action.type
    when 'user.check'
      update state,
        checkedKeys: 
          checked: 
            $set: action.users
    when 'user.collapse'
      update state,
        expandedKeys:
          $set:  _.difference state.expandedKeys, action.emails
    when 'user.list.ok'
      { users, user } = action.data
      update state,
        user: 
          $set: user
        users:
          $set: users
    when 'user.collapseAll'
      update state,
        expandedKeys:
          $set: []
    when 'user.expand.ok'
      { users, user } = action.data
      update state,
        expandedKeys: 
          $set: state.expandedKeys.concat [user.email]
        user:
          $set: user
        users:
          $set: users
    when 'user.create.ok'
      { users, user } = action.data
      update state,
        user:
          $set: user
        users:
          $set: users
    when 'user.update.ok'
      { users, user } = action.data
      update state,
        expandedKeys: 
          $set: _.uniq state.expandedKeys.concat [user.email]
        user: 
          $set: user
        users: 
          $set: users
    when 'user.delete.ok'
      { users, user } = action.data
      update state,
        checkedKeys: 
          checked:
            $set: _.filter state.checkedKeys.checked, (email) ->
              email != user.email
        expandedKeys: 
          $set: _.filter state.expandedKeys, (email) ->
            email != user.email
        user: 
          $set: user
        users:
          $set: users
    when 'user.expandAll.ok'
      { users, user } = action.data
      update state,
        expandedKeys:
          $apply: ->
            for user from User.bfs users
              user.email
        users:
          $set: users
        user:
          $set: user
    else
      state || initState

actionCreator = (dispatch) ->
  getUsers: ->
    dispatch
      type: 'user.list'
  expandAll: ->
    dispatch
      type: 'user.expandAll'
  collapseAll: ->
    dispatch
      type: 'user.collapseAll'
  check: (users) ->
    dispatch
      type: 'user.check'
      users: users
  collapse: (emails) ->
    dispatch 
      type: 'user.collapse'
      emails: emails
  addUser: (email) ->
    dispatch
      type: 'user.create'
      email: email
  getUser: (email) ->
    dispatch 
      type: 'user.expand'
      email: email
    Promise.resolve()
  putUser: (email, supervisor) ->
    dispatch
      type: 'user.update'
      email: email
      supervisor: supervisor
  delUser: (email) ->
    dispatch 
      type: 'user.delete'
      email: email
      
module.exports =
  component: Users
  state: initState
  reducer: reducer
  actionCreator: actionCreator
