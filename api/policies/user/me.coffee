module.exports = (req, res, next) ->
	req.options.where ?= {}
	req.options.where.id = req.user.id
	next()