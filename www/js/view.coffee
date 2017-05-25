React = require 'react'
R = React.DOM
rest = require './model.coffee'
Tree = require 'rc-tree'
_ = require 'lodash'

class Users extends Tree
  componentDidMount: ->
    @props.dispatch rest.actions.users.sync sort: 'email ASC'

  render: ->
    React.createElement Tree, @props, @props.users.data?.results?.map (user) ->
      children = user.subordinates?.map (user) ->
        React.createElement Tree.TreeNode, _.defaults user,
          key: user.email
          title: user.email
          isLeaf: false
          expanded: false
      props = _.defaults user,
        key: user.email
        title: user.email
        isLeaf: false
        expanded: false
      React.createElement Tree.TreeNode, props, children

module.exports =
  Users: Users
