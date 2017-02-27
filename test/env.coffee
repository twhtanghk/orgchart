module.exports =
	timeout: 4000000
	client: 
		id:		'client id'
		secret: 'client secret'
	users: [
		{ id: 'user1', secret: 'secret' }
		{ id: 'user2', secret: 'secret' }
	]
	getTokens: ->
		new Promise (fulfill, reject) ->
			url = process.env.TOKENURL
			scope = process.env.OAUTH2_SCOPE?.split(' ') || [ 'User', 'Mobile' ]
			Promise
				.all [
					sails.services.oauth2.token url, module.exports.client, module.exports.users[0], scope
					sails.services.oauth2.token url, module.exports.client, module.exports.users[1], scope
				] 
				.then (res) ->
					fulfill _.map res, (response) ->
						response.body.access_token
				.catch reject
	getUsers: ->
		sails.models.user
			.find username: _.map module.exports.users, (user) ->
				user.id