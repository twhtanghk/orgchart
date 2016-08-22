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

		class OauthUser extends pageableAR.Model
			$idAttribute: 'username'		
			$urlRoot: "#{env.server.rest.urlRoot}/api/users/"
		
		
		class OauthUsers extends pageableAR.PageableCollection
			model: OauthUser
			$urlRoot: "#{env.server.rest.urlRoot}/api/users/"	


		User:		User
		OrgChart:	OrgChart
		OauthUser:	OauthUser
		OauthUsers:	OauthUsers
