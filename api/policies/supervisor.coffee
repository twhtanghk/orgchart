_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  cond = actionUtil.parseCriteria req
  if _.isEmpty cond
    req.options.where ?= {}
    req.options.where.supervisor = req.query.supervisor || null
  next()
