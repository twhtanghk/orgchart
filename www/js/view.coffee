React = require 'react'
R = React.DOM
rest = require './model.coffee'

class Users extends React.Component
  componentDidMount: ->
    @props.dispatch rest.actions.users.sync()

  render: ->
    if 'users' of @props
      R.div {}, @props.users.data.results?.map (user) ->
        R.div key: user.id, user.email
    else
      R.div()

module.exports =
  Users: Users
