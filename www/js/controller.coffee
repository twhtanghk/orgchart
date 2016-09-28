env = require './env.coffee'
Promise = require 'promise'
	

angular
	.module 'starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']		
	.controller 'MenuCtrl', ($scope) ->
		$scope.env = env
		$scope.navigator = navigator
		
	.controller 'OrgChartCtrl', ($scope, collection, $location, resources, userList) ->
		_.extend $scope,
			expandedNodes: []
			listView: false
			userList: userList
			collection: collection
			showToggle: (node, expanded, $parentNode) ->
				if expanded
					Promise
						.all _.map node.subordinates, (child) ->
							if child.subordinates.length == 0
								subordinate = new resources.User id: child.id
								subordinate.$fetch()
							else
								return child
						.then (data)->
							node.subordinates = data
							$scope.$apply()
							test = $scope.collection
							return node.subordinates
			select: (nodes, user) ->
				if nodes == null
					new resources.User.root(user)
						.then (rootSupervisor) ->
							match = _.findWhere $scope.collection, {id: rootSupervisor.id}
							if match
								i = _.indexOf($scope.collection, match)
								$scope.expandedNodes.push $scope.collection[i]
								$scope.showToggle($scope.collection[i], true)
									.then (data) ->
										$scope.select(data, user)
				else
					_.each nodes, (node) ->
						if node.id != user.id
							$scope.expandedNodes.push node
							$scope.showToggle(node, true)
								.then (data) ->
									$scope.select(data, user)
			hide: ->
				$scope.listView = false
			show: ->
				$scope.listView = true
		
			
	.controller 'UserUpdateCtrl', ($scope, $state, $location, me, collection) ->	
		collection.page = 1
		_.extend $scope,
			userList: false
			model: me
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
				
	.filter 'UserFilter', ->
		(user, search) ->
			r = new RegExp(search, 'i')
			if search
				return _.filter user, (item) ->
					r.test(item?.username) or r.test(item?.email)	
			else
				return user

