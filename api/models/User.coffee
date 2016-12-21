 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
	
	tableName:	'users'
	
	schema: true
	
	attributes:
		url:
			type: 'string'
			required: true
		username:
			type: 'string'
			required: true
		email:
			type: 'string'
			required: true
			unique: true
		supervisor:
			model: 'user'
		subordinates:
			collection: 'user'
			via: 'supervisor'

	admin: (cb) ->
		ret = sails.models.user
			.findOne username: sails.config.adminUser.username
				
		if cb
			ret.nodeify cb
			return @
		return ret 

