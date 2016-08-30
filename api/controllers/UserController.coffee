 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
Promise = require 'promise'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
querystring = require 'querystring'

module.exports =		
	findOauth2User: (req, res) ->
		Model = actionUtil.parseModel req
		cond = actionUtil.parseCriteria req
		url = sails.config.oauth2.userURL
		
		
		sails.services.rest().get req.user.token, "#{url}?#{querystring.stringify(cond)}"
			.then (res2) ->
				res.ok res2.body
			.catch res.serverError