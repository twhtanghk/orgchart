actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res) ->
  Model = actionUtil.parseModel req
  cond = actionUtil.parseCriteria req

  Model
    .find()
    .where cond
    .populate 'subordinates'
    .sort actionUtil.parseSort req
    .then res.ok, res.serverError
