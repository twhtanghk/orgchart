env = require './env.coffee'
	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator

SearchUserCtrl = ($scope, collection, $location, model) ->
	_.extend $scope,
		collection: collection
		select: (id) ->
			$location.url "/orgchart?id=#{id}"	
		loadMore: ->
			collection.$fetch({params: {sort: 'name ASC'}})
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
			return @
		
OrgChartCtrl = ($stateParams, $scope, collection, $location, model, cliModel) ->

	update = (arr, key, newval) ->
		match = _.find(arr, {subordinates:[key]})
		if match
			index = _.indexOf(arr, match)
			
			subArr = arr[index].subordinates
			obj = _.find(subArr, key)
			if obj
				i = _.indexOf(subArr, obj)
				subArr[i] = newval	
		else
			_.each arr, (obj) ->
				if obj.subordinates.length != 0
					update(obj.subordinates, key, newval)
		return
		
	###
	getTree = () ->
		treedata = _.filter collection.models, (user) ->
					_.isUndefined user.supervisor
		
		if $stateParams.id
			return treedata
		else
			return treedata
	###
	_.extend $scope,
		treedata: _.filter collection.models, (user) ->
					_.isUndefined user.supervisor
		treeOptions:
			nodeChildren: "subordinates"
			dirSelectable: true
			injectClasses:
				ul: "a1"
				li: "a2"
				liSelected: "a7"
				iExpanded: "a3"
				iCollapsed: "a4"
				iLeaf: "a5"
				label: "a6"
				labelSelected: "a8"
		showSelected: (node, index, parentNode) ->
			$scope.selectedNode = node	
			User = new cliModel.User id: node.id
			User.$fetch()
				.then (data)->
					update($scope.treedata, {id:node.id}, data)
		search: () ->
			$location.url "/orgchart/search"	
					
					
	
UserUpdateCtrl = ($scope, $state, $location, model, collection) ->
	
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

UserFilter = ->
	(user, search) ->
		r = new RegExp(search, 'i')
		if search
			return _.filter user, (item) ->
				r.test(item?.username) or r.test(item?.email)	
		else
			return user


config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'OrgChartCtrl', ['$stateParams', '$scope', 'collection', '$location', 'model', 'cliModel', OrgChartCtrl]
angular.module('starter.controller').controller 'SearchUserCtrl', ['$scope', 'collection', '$location', 'model', SearchUserCtrl]
angular.module('starter.controller').controller 'UserUpdateCtrl', ['$scope', '$state', '$location', 'model','collection', UserUpdateCtrl]
angular.module('starter.controller').filter 'UserFilter', UserFilter