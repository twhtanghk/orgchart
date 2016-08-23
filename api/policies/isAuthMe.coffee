actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
isAuth = require './isAuth.coffee'

module.exports = (req, res, next) ->
	if actionUtil.requirePk(req) == 'me'
		isAuth(req, res, next)
	else
		next()