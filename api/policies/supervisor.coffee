actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  req.options.where ?= {}
  req.options.where.supervisor = req.query.supervisor || null
  next()
