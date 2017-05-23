React = require 'react'
R = React.DOM
rest = require './model.coffee'
Tree = require 'rc-tree'
_ = require 'lodash'

class User extends Tree.TreeNode

class Users extends Tree
  componentDidMount: ->
    @props.dispatch rest.actions.users.sync()

  render: ->
    React.createElement Tree, {}, @props.users.data?.results?.map (user) ->
      defaults =
        key: user.id
        title: user.email
      React.createElement User, _.extend defaults, user

module.exports =
  Users: Users
