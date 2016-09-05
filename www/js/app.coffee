env = require './env.coffee'

angular.module 'starter', ['ionic', 'starter.controller', 'starter.model', 'ActiveRecord', 'angular.filter', 'util.auth', 'treeControl']

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

		$stateProvider.state 'app.update',
			url: '/update'
			cache: false
			views:
				menuContent:
					templateUrl: 'templates/user/update.html'
					controller: 'UserUpdateCtrl'
			resolve:
				cliModel: 'model'
				model: (cliModel) ->
					cliModel.User.me().$fetch()
				collection: (cliModel) ->
					ret = new cliModel.Oauth2Users()
					#ret.$fetch({params: {sort: 'name ASC'}})

		$stateProvider.state 'app.searchOrgchart',
			url: "/orgchart/search"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/orgchart/search.html"
					controller: 'SearchUserCtrl'
			resolve:
				cliModel: 'model'
				collection: (cliModel) ->
					ret = new cliModel.OrgChart()
					ret.$fetch({params: {sort: 'name ASC'}})
				
		$stateProvider.state 'app.orgchart',
			url: "/orgchart?id"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/orgchart/list.html"
					controller: 'OrgChartCtrl'
			resolve:
				id: ($stateParams) ->
					$stateParams.id
				cliModel: 'model'
				model: (cliModel) ->
					ret = new cliModel.User()
				collection: (cliModel) ->
					ret = new cliModel.OrgChart()
					ret.$fetch({params: {sort: 'name ASC'}})

		$urlRouterProvider.otherwise('/orgchart')