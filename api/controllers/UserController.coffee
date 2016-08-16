 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
Promise = require 'promise'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	findSuper: (req, res)->
		opts = actionUtil.opts req
		opts.model
			.findOne()
			.where {id:opts.where.id}
			.populateAll()
			.then (record) ->
				if record
					res.ok record.supervisor
				else
					res.notFound()
			.catch res.serverError
		
	updateSuper: (req, res) ->
		opts = actionUtil.opts req
		queryMe = opts.model.findOne()
			.where {id:opts.where.id}
			.toPromise()
		querySuper = opts.model.findOne()
			.where({username:opts.where.supervisor})
			.toPromise()
		
		new Promise (fulfill, reject) ->
			Promise.all([queryMe, querySuper])
				.then (data) ->
					if data[1]
						data[1].subordinates.add data[0]
						data[1].save()
						res.ok()
					else
						res.notFound() #supervisor not found
				.catch res.serverError
	
	deleteSuper: (req, res) ->
		opts = actionUtil.opts req
		opts.model
			.update({id:opts.where.id}, {supervisor:null})
			.then res.ok()
			.catch res.serverError
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
				
