actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
	
	req.options.id = req.user.id
	values = actionUtil.parseValues(req)
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