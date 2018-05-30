path = require 'path'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
  if actionUtil.requirePk(req) == 'me'
    opts = path.parse req.url
    req.url = path.join opts.dir, req.user.id
  next()	
