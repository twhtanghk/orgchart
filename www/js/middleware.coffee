rest = require './model.coffee'

module.exports = 
  (store) -> (next) -> (action) ->
    if action.error == 'Unauthorized'
      next type: 'login'
    next action
