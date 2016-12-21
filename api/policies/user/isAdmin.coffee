actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
	
	values = actionUtil.parseValues(req)
	
	noRecord =
		count:		0
		results:	[]
	
	sails.models.user.admin()
		.then (admin) ->
			admID = admin.id
			if req.user.id == admin.id
				return next()
			else
				return res.ok noRecord

	