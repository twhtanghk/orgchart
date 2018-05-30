actionUtil = require 'sails/lib/hooks/blueprints/actionUtil.js'

module.exports =
  create: (req, res) ->
    sails.models.user.updateCreate actionUtil.parseValues req
      .then res.ok, res.serverError
