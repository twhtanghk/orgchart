http = require 'needle'
fs = require 'fs'
Promise = require 'promise'
util = require 'util'

dir = '/etc/ssl/certs'
files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
files = files.map (file) -> "#{dir}/#{file}"
ca = files.map (file) -> fs.readFileSync file

module.exports = (options = sails.config.http.opts || {}) ->
	_.defaults options, 
		ca:			ca
	
	get: (token, url) ->
		sails.log.debug "rest get token: #{token}"
		sails.log.debug "rest get url: #{url}"
		new Promise (fulfill, reject) ->
			opts =
				headers:
					Authorization:	"Bearer #{token}"
			_.extend opts, options
			http.get url, opts, (err, res) ->
				if err
					return reject err
				fulfill res
				
	post: (token, url, data) ->
		new Promise (fulfill, reject) ->
			opts =
				headers:
					Authorization:	"Bearer #{token}"
			_.extend opts, options
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res
								
	# get token for Resource Owner Password Credentials Grant
	# url: 	authorization server url to get token 
	# client:
	#	id: 	registered client id
	#	secret:	client secret
	# user:
	#	id:		registered user id
	#	secret:	user password
	# scope:	[ "https://mob.myvnc.com/org/users", "https://mob.myvnc.com/mobile"]
	token: (url, client, user, scope) ->
		opts = 
			'Content-Type':	'application/x-www-form-urlencoded'
			username:		client.id
			password:		client.secret
		_.extend opts, options
		data =
			grant_type: 	'password'
			username:		user.id
			password:		user.secret 
			scope:			scope.join(' ')
		new Promise (fulfill, reject) ->
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res