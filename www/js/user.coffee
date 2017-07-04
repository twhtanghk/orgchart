React = require 'react'
E = require 'react-script'
rest = require './model.coffee'
Tree = require 'rc-tree'
update = require 'react-addons-update'
Promise = require 'bluebird'
_ = require 'lodash'
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

find = (user, users) ->
  cb = (initVal, node) ->
    if initVal?
      initVal
    else if node.email == user.email
      node
    else
      _.reduce node.subordinates, cb, initVal
  _.reduce users.results, cb, null

del = (user, users) ->
  cb = (nodes) ->
    ret = _.filter nodes, (node) ->
      node.email != user.email
    ret.map (node) ->
      node.subordinates = cb node.subordinates
    ret
  cb users

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
    size: 17
    showIcon: false
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

  render: ->
    node = (user) =>
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
      E Tree.TreeNode, props, user.subordinates?.map node
    E 'div',
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
        @props.users.results?.map node
      E SpeedDial,
        hasBackdrop: false,
        E BubbleList,
          E BubbleListItem,
            primaryText: 'Add'
            rightAvatar: E Avatar, icon: E Add
            onTouchTap: @openAdd
          E BubbleListItem,
            primaryText: 'Delete'
            rightAvatar: E Avatar, icon: E Delete
            onTouchTap: @del
          E BubbleListItem,
            primaryText: 'Expand All'
            rightAvatar: E Avatar, icon: E Expand
            onTouchTap: @expandAll
          E BubbleListItem,
            primaryText: 'Collapse All'
            rightAvatar: E Avatar, icon: E Collapse
            onTouchTap: @collapseAll

initState =
  checkedKeys:
    checked: []
  expandedKeys: []
  users: 
    count: 0
    result: []
  user: {}

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
    when 'user.getAll.ok'
      update state,
        users: 
          $set: action.data
    when 'user.expand.ok'
      update state,
        expandedKeys: 
          $set: _.reduce action.data, traverse, []
        users: 
          $set: results: action.data
    when 'user.collapseAll'
      update state,
        expandedKeys:
          $set: []
    when 'user.getOne.ok'
      update state,
        expandedKeys: 
          $set: state.expandedKeys.concat [action.data.email]
        user: 
          $set: action.data
        users: 
          $set: merge action.data, state.users
    when 'user.put.ok'
      update state,
        expandedKeys: 
          $set: _.uniq state.expandedKeys.concat [action.data.email]
        user: 
          $set: action.data
        users: 
          $set: merge action.data, state.users
    when 'user.del.ok'
      update state,
        checkedKeys: 
          checked:
            $set: _.filter state.checkedKeys.checked, (email) ->
              email != action.data.email
        expandedKeys: 
          $set: _.filter state.expandedKeys, (email) ->
            email != action.data.email
        user: 
          $set: action.data
        users:
          count: 
            $set: state.users.count - 1
          results: 
            $set: del state.users.results
    else
      state || initState

actionCreator = (dispatch) ->
  getUsers: ->
    dispatch
      type: 'user.getAll'
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
      type: 'user.post'
      email: email
  getUser: (email) ->
    dispatch 
      type: 'user.getOne'
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
