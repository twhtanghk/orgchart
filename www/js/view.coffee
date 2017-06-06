env = require './config.json'
React = require 'react'
E = require 'react-script'
rest = require './model.coffee'
Tree = require 'rc-tree'
Dialog = require 'rc-dialog'
update = require 'react-addons-update'
Promise = require 'bluebird'

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
        .then =>
          if oldSup?
            @getUser oldSup
          else
            @getUsers()
        .then =>
          @getUser newSup
        .catch (err) ->
          if err != 'Unauthorized'
            Promise.reject err

  componentDidMount: ->
    @props.getUsers()

  render: ->
    node = (user) ->
      props = Object.assign {key: user.email, title: user.email}, user
      E Tree.TreeNode, props, user.subordinates?.map node
    E Tree, @props, @props.users.data?.results?.map node

module.exports =
  Auth: require 'rc-oauth2'
  Users: Users
