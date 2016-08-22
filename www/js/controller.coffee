env = require './env.coffee'
	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator

OrgChartCtrl = ($scope, collection, $location, model) ->
	
	_.extend $scope,
		treedata: collection.models

UserUpdateCtrl = ($scope, $state, $location, model, collection) ->
	
	collection.page = 1
	_.extend $scope,
		userList: false
		model: model
		collection: collection
		read: (obj) ->
			$scope.model.supervisor = obj
		save: ->
			user = $scope.model
			user.$save().then =>
				$location.url "/user"
		show: (val)->
			$scope.userList=val
		loadMore: ->
			if _.isUndefined collection.page
				collection.page = collection.state.skip/collection.state.limit + 1
			else
				collection.page = collection.page + 1
			collection.state.skip = 0
			
			collection.$fetch({params: {sort: 'name ASC', page: collection.page}})
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
			return @


config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'OrgChartCtrl', ['$scope', 'collection', '$location', 'model', OrgChartCtrl]
angular.module('starter.controller').controller 'UserUpdateCtrl', ['$scope', '$state', '$location', 'model','collection', UserUpdateCtrl]