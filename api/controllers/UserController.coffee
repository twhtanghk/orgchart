 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	findSuper: (req, res)->
		opts = actionUtil.opts req
		opts.model
			.findOne()
			.where opts.where
			.populateAll()
			.then (record) ->
				if record
					res.ok record.supervisor
				else
					res.notFound()
			.catch res.serverError
		
