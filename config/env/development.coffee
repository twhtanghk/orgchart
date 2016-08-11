agent = require 'https-proxy-agent'

module.exports =
	hookTimeout:	400000
	
	port:			1337

	http:
		opts:
			agent:	new agent("http://proxy1.scig.gov.hk:8080")				
	
	oauth2:
		verifyURL:			"https://mob.myvnc.com/org/oauth2/verify/"
		tokenURL:			"https://mob.myvnc.com/org/oauth2/token/"
		scope:				["https://mob.myvnc.com/org/users"]

	promise:
		timeout:	10000 # ms

	models:
		connection: 'mongo'
		migrate:	'alter'
	
	connections:
		mongo:
			adapter:	'sails-mongo'
			driver:		'mongodb'
			host:		'localhost'
			port:		27017
			user:		''
			password:	''
			database:	'orgchartDB'	
			
	log:
		level: 'info'
		
			