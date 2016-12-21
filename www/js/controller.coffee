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
			showInfo: (node) ->			
				$scope.$emit 'userInfo', node 
			showToggle: (node, expanded) ->
				if expanded
					$scope.expandedNodes.push node
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
							return node.subordinates
				else
					i = _.indexOf($scope.expandedNodes, node)
					$scope.expandedNodes.splice i, 1
			select: (nodes, user) ->
				if nodes == null
					new resources.User.root(user)
						.then (rootSupervisor) ->
							match = _.findWhere $scope.collection, {id: rootSupervisor.id}
							if match
								i = _.indexOf($scope.collection, match)
								if user.id == rootSupervisor.id
									$scope.selected = $scope.collection[i]
									$scope.$apply()
								else
									$scope.expandedNodes.push $scope.collection[i]
									$scope.showToggle($scope.collection[i], true)
										.then (data) ->
											$scope.select(data, user)
				else
					_.every nodes, (node) ->
						if node.id != user.id
							$scope.expandedNodes.push node
							$scope.showToggle(node, true)
								.then (data) ->
									$scope.select(data, user)
						else
							$scope.selected = node
							$scope.$apply()
			hide: ->
				$scope.listView = false
			show: ->
				$scope.listView = true			
			
	.controller 'UserUpdateCtrl', ($scope, $state, $location, me, collection, resources, adminSelectUsers) ->	
		collection.page = 1
		_.extend $scope,
			model: me
			collection: collection
			userList: adminSelectUsers
			loadMore: ->
				if _.isUndefined collection.page
					collection.page = collection.state.skip/collection.state.limit + 1
				else
					collection.page = collection.page + 1
				collection.state.skip = 0
				
				collection.$fetch({params: {sort: 'name ASC', page: collection.page}})
					.then (data) ->
						resources.User.subord(me, [])
							.then (result) ->
								result.push me.email
								data.models = _.filter data.models, (user) ->
									_.indexOf(result, user.email) == -1
								$scope.$apply()						
						$scope.$broadcast('scrollCompleted')
					.catch alert
				return @
			
			save: ->
				user = $scope.model
				user.$save().then =>
					$location.url "/orgchart"
					$state.reload()
			reset: ->
				$scope.model.supervisor = null
				$scope.save()
				
	.filter 'UserFilter', ->
		(user, search) ->
			r = new RegExp(search, 'i')
			if search
				return _.filter user, (item) ->
					r.test(item?.username) or r.test(item?.email)	
			else
				return user

