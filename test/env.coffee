_ = require 'lodash'

module.exports =
	timeout: 4000000
	client: 
		id:		process.env.CLIENT_ID
		secret: process.env.CLIENT_SECRET
	users: [
		{ username: 'user1', url: 'user1@abc.com', email: 'user1@abc.com' }
		{ username: 'user2', url: 'user2@abc.com', email: 'user2@abc.com' }
	]
	getTokens: ->
		new Promise (fulfill, reject) ->
			url = process.env.TOKENURL
			scope = process.env.OAUTH2_SCOPE?.split(' ') || [ 'User', 'Mobile' ]
			Promise
				.all [
					sails.services.rest().token url, module.exports.client, module.exports.users[0], scope
					sails.services.rest().token url, module.exports.client, module.exports.users[1], scope
				] 
				.then (res) ->
					fulfill _.map res, (response) ->
						response.body.access_token
				.catch reject
	getUsers: ->
		sails.models.user
			.find username: _.map module.exports.users, (user) ->
				user.id