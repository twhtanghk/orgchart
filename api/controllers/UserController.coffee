 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
Promise = require 'promise'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
querystring = require 'querystring'

module.exports =		
	findOauth2User: (req, res) ->
		cond = actionUtil.parseCriteria req
		url = sails.config.oauth2.userURL
		values = actionUtil.parseValues(req)
		
		strCond = querystring.stringify(cond)
		
		if values.skip != null & parseInt(values.skip) > 0 && strCond.length==0
			strCond = "page=#{(parseInt(values.skip) + 10)/10}"
	
		sails.services.rest().get req.user.token, "#{url}?#{strCond}"
			.then (res2) ->
				res.ok res2.body
			.catch res.serverError
	
	findPageableUser: (req, res) ->
		sails.services.crud
			.find(req)
			.then res.ok
			.catch res.serverError
	update: (req, res) ->
		pk = actionUtil.requirePk(req)
		user = actionUtil.parseValues(req)

		#check whether user is admin
		sails.models.user.admin()
			.then (admin) ->
				if pk == admin.id
					pk = user.selUser.id

		if (user.supervisor == null || _.isUndefined user.supervisor)
			sails.models.user.update(pk, user)
				.then (updatedRecord) ->
					res.ok updatedRecord
				.catch res.serverError
		else		
			sails.models.user.findOne()
				.where({id: user.supervisor.id})
				.populateAll()
				.then (supervisor) ->
					supervisor.subordinates.add pk
					supervisor.save()
					res.ok user
				.catch res.serverError
	findForSelect: (req, res) ->
		@findPageableUser(req, res)
	
			
	