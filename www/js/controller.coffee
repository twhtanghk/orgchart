env = require './env.coffee'
Promise = require 'promise'
	

angular
	.module 'starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']		
	.controller 'MenuCtrl', ($scope) ->
		$scope.env = env
		$scope.navigator = navigator
		
	.controller 'OrgChartCtrl', ($stateParams, $scope, collection, $location, cliModel) ->
		_.extend $scope,
			collection: collection
			
	.controller 'UserUpdateCtrl', ($scope, $state, $location, model, collection) ->	
		collection.$fetch({params: {sort: 'name ASC'}})
		collection.page = 1
		_.extend $scope,
			userList: false
			model: model
			collection: collection
			select: (obj) ->
				$scope.model.supervisor = obj
				$scope.userList = false
			show: ->
				$scope.userList = true
			save: ->
				user = $scope.model
				user.$save().then =>
					$location.url "/user"
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

	.filter 'UserFilter', (user, search) ->
		r = new RegExp(search, 'i')
		if search
			return _.filter user, (item) ->
				r.test(item?.username) or r.test(item?.email)	
		else
			return user

