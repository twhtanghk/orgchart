actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  if actionUtil.requirePk(req) == 'me'
    req.options.where ?= {}
    req.options.where.id = req.user.email
  next()	
