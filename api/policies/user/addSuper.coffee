actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
	
	values = actionUtil.parseValues(req)
	if values.supervisor
		user = _.pick values.supervisor, 'url', 'username', 'email'
		sails.models.user
			.findOrCreate user
			.then (supervisor) ->
				if supervisor
					req.options.values.supervisor = supervisor
					return next()
				else
					return res.notFound()
			.catch res.serverError
	else
		return next()