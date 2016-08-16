env = require './env.coffee'
gmu = require 'googlemaps-utils'
geolib = require 'geolib'


currentPosReady = ->
	coords = env.map.coords
	return new Promise (fulfill, reject) ->
		options = 
			timeout: 60000
			enableHighAccuracy: true
		watchID = undefined
		
		showLocation = (position) ->
			fulfill
				latitude: Number(Math.round(position.coords.latitude+'e6')+'e-6')
				longitude: Number(Math.round(position.coords.longitude+'e6')+'e-6')

		errorHandler = (err) ->
			fulfill coords
		
		if navigator.geolocation
			
			watchID = navigator.geolocation.getCurrentPosition(showLocation, errorHandler, options)
		else
			fulfill coords

getMapSize = ->
	mapHeight = env.mapSize.height

	if screen.height < mapHeight
		mapHeight = screen.height
	
	return {width: screen.width, height: mapHeight}

angular.module 'starter', ['ionic', 'starter.controller', 'starter.model', 'ngTagEditor', 'ActiveRecord', 'angular.filter', 'util.auth', 'uiGmapgoogle-maps']

	.run (authService) ->
		authService.login env.oauth2.opts
		
	.run ($rootScope, platform, $ionicPlatform, $location, $http) ->
		$ionicPlatform.ready ->
			if (window.cordova && window.cordova.plugins.Keyboard)
				cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
			if (window.StatusBar)
				StatusBar.styleDefault()
	.config (uiGmapGoogleMapApiProvider) ->
		uiGmapGoogleMapApiProvider.configure
			v:	'3.20'
			libraries:	'places,weather,geometry,visualization'
								
	.config ($stateProvider, $urlRouterProvider) ->
		$stateProvider.state 'app',
			url: ""
			abstract: true
			templateUrl: "templates/menu.html"

		$stateProvider.state 'app.hotspot',
			url: "/hotspot"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/hotspot/list.html"
					controller: 'HotspotListCtrl'
			resolve:
				cliModel: 'model'
				collection: (cliModel) ->
					ret = new cliModel.HotspotList()
					ret.$fetch({params: {sort: 'name ASC'}})
		
		$stateProvider.state 'app.map',
			url: "/map"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/hotspot/map.html"
					controller: 'geoCtrl'
			resolve:
				cliModel: 'model'
				geoModel: (cliModel) ->
					ret = new cliModel.geoHotspot()
				coords: () ->
					currentPosReady()
						.then (pos) ->
							ret = pos
				distance: (coords) ->
					mapSize = getMapSize()
					bounds = gmu.calcBounds(coords.latitude, coords.longitude, env.map.zoom, mapSize.width, mapSize.height)
					ret = geolib.getDistance(coords, {latitude: bounds.bottom, longitude: bounds.left})
					
				collection: (cliModel, coords, distance) ->
					ret = new cliModel.MapList()
					ret.$fetch({params: {longitude: coords.longitude, latitude: coords.latitude, distance: distance/1000 }})

		$stateProvider.state 'app.readHotspot',
			url: "/hotspot/read/:id"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/hotspot/read.html"
					controller: 'HotspotCtrl'
			resolve:
				id: ($stateParams) ->
					$stateParams.id
				cliModel: 'model'
				model: (cliModel, id) ->
					ret = new cliModel.Hotspot({id: id})
					ret.$fetch()


		$stateProvider.state 'app.createHotspot',
			url: "/hotspot/create"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/hotspot/create.html"
					#controller: "createHotspotCtrl"
					controller: 'HotspotCtrl'
			resolve:
				cliModel: 'model'	
				model: (cliModel) ->
					ret = new cliModel.Hotspot()

	
		$stateProvider.state 'app.editHotspot',
			url: "/hotspot/edit/:id"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/hotspot/edit.html"
					controller: 'HotspotCtrl'
			resolve:
				id: ($stateParams) ->
					$stateParams.id
				cliModel: 'model'	
				model: (cliModel, id) ->
					ret = new cliModel.Hotspot({id: id})
					ret.$fetch()
						.then () ->
							ret.origTagID = _.map ret.tags, (tag) ->
								tag.id
							return ret

		$urlRouterProvider.otherwise('/map')