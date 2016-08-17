env = require './env.coffee'
require 'PageableAR'


angular.module 'starter.model', ['PageableAR']
	
	.factory 'model', (pageableAR, $filter, $http) ->

		class User extends pageableAR.Model
			$idAttribute: 'username'
			
			$urlRoot: "api/user/"
			
			_me = null
			
			@me: ->
				_me ?= new User username: 'me'

		User:		User
