 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
Promise = require 'promise'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	findMe: (req, res) ->
		opts = actionUtil.opts req
		opts.model
			.findOne()
			.where {id:opts.where.id}
			.populateAll()
			.then (me) ->
				if me
					res.ok me
				else
					res.notFound()
			.catch res.serverError
	update: (req, res) ->
		opts = actionUtil.opts req
		pk = actionUtil.requirePk(req)
		values = actionUtil.parseValues(req)

		user = _.pick values.supervisor, 'url', 'username', 'email'
		opts.model
			.findOrCreate user
			.then (instance) ->
				opts.model
					.update(pk, {supervisor:instance})
					.then (results) ->
						res.ok results
					.catch res.serverError
			.catch res.serverError

