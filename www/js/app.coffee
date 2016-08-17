env = require './env.coffee'

angular.module 'starter', ['ionic', 'starter.controller', 'starter.model', 'ActiveRecord', 'angular.filter', 'util.auth']

	.run (authService) ->
		authService.login env.oauth2.opts
		
	.run ($rootScope, platform, $ionicPlatform, $location, $http) ->
		$ionicPlatform.ready ->
			if (window.cordova && window.cordova.plugins.Keyboard)
				cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
			if (window.StatusBar)
				StatusBar.styleDefault()
							
	.config ($stateProvider, $urlRouterProvider) ->
		$stateProvider.state 'app',
			url: ""
			abstract: true
			templateUrl: "templates/menu.html"

		$stateProvider.state 'app.user.update',
			url: '/update'
			views:
				userContent:
					templateUrl: 'templates/user/update.html'
					controller: 'UserUpdateCtrl'
			resolve:
				resource: 'resource'
				model: (resource) ->
					resource.User.me().$fetch()

		$stateProvider.state 'app.orgchart',
			url: "/orgchart"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/orgchart/list.html"
					controller: 'UserListCtrl'

		$urlRouterProvider.otherwise('/orgchart')