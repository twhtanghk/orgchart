 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
Promise = require 'promise'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	find: (req, res) ->
		Model = actionUtil.parseModel req
		cond = actionUtil.parseCriteria req
		
		count = Model.count()
			.where( cond )
			.toPromise()
		
		query = Model.find()
		 	.where( cond )
			.populateAll()
			.limit( actionUtil.parseLimit(req) )
			.skip( actionUtil.parseSkip(req) )
			.sort( actionUtil.parseSort(req) )
			.toPromise()
		###
		query = Model.findOne()
			.where({email: "jokyip@ogcio.gov.hk"})
			.populateAll()
			.toPromise()
			.then (data) ->
				sails.log.debug "data: #{JSON.stringify(data)}"
		
		query = Model.findOne()
			.where({email: "jokyip@ogcio.gov.hk"})
			.populate('supervisor')
			.toPromise()
			.then (user) ->
				
				getSuper = (user) ->
					
					sails.log.debug "superobj: #{_.isObject user.supervisor}"

					superid = if _.isObject(user.supervisor) then user.supervisor.id else user.supervisor
					sails.log.debug "superid: #{superid}"	
						
					supervisor = sails.models.user
						.findOne(superid)
						.populateAll()
						.toPromise()
						.then (data) ->
							sails.log.debug "supervisor: #{JSON.stringify(data.supervisor)}"
							if data.supervisor.supervisor
								getSuper data.supervisor
							else
								return data
				
				getSuper(user)		
				
				
				new Promise (fulfill, reject) ->
					Promise.all([user, supervisor])
						.then (data) ->
							fulfill data
						.catch reject
						
			.spread (user, supervisor) ->
				user.supervisor = supervisor
				return user
			.catch res.serverError
		###
		Promise.all([count, query])
			.then (data) ->
				val =
					count:		data[0]
					results:	data[1]
				res.ok(val)
			.catch res.serverError