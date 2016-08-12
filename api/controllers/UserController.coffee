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
		
	updateSuper: (req, res) ->
		opts = actionUtil.opts req
		opts.model
			.findOne()
			.where {id:opts.where.id}
			.then (me) ->
				opts.model
					.findOne()
					.where({username:opts.where.supervisor})
					.populateAll()
					.then (superInstance) ->
						if superInstance
							superInstance.subordinates.add me
							superInstance.save()
							res.ok me
						else
							res.notFound() #supervisor not found
					.catch res.serverError
			.catch res.serverError