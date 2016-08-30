env = require './env.coffee'
require 'PageableAR'


angular.module 'starter.model', ['PageableAR']
	
	.factory 'model', (pageableAR, $filter, $http) ->

		class User extends pageableAR.Model
			$idAttribute: 'id'
			
			$urlRoot: "api/user/"
			
			_me = null
			
			@me: ->
				_me ?= new User id: 'me'
		
		class OrgChart extends pageableAR.PageableCollection
			model: User
		
			$urlRoot: "api/user/"		

		class Oauth2User extends pageableAR.Model
			$idAttribute: 'username'		
			$urlRoot: "api/oauth2/user/"
			#$urlRoot: "#{env.server.rest.urlRoot}/api/users/"
		
		
		class Oauth2Users extends pageableAR.PageableCollection
			model: Oauth2User
			$urlRoot: "api/oauth2/user/"
			#$urlRoot: "#{env.server.rest.urlRoot}/api/users/"	


		User:		User
		OrgChart:	OrgChart
		Oauth2User:	Oauth2User
		Oauth2Users:	Oauth2Users
