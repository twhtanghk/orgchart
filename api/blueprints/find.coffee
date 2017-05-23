Promise = require 'bluebird'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res) ->
  Model = actionUtil.parseModel req
  cond = actionUtil.parseCriteria req

  count = Model
    .count()
    .where cond
    .toPromise()
  query = Model
    .find()
    .where cond
    .limit actionUtil.parseLimit req
    .skip actionUtil.parseSkip req
    .sort actionUtil.parseSort req
    .toPromise()

  Promise
    .all [count, query]
    .then (result) ->
      count: result[0]
      results: result[1]
    .then res.ok, res.serverError
