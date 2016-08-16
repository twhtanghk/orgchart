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

		class Tag extends pageableAR.Model
			$idAttribute: 'id'
			
			$urlRoot: "api/tag/"
		
		class Hotspot extends pageableAR.Model
			$idAttribute: 'id'
			
			$urlRoot: "api/hotspot/"	
		
		class HotspotList extends pageableAR.PageableCollection
			model: Hotspot
		
			$urlRoot: "api/hotspot/"
			
		class geoHotspot extends pageableAR.Model
			$idAttribute: '_id'
			
			$urlRoot: "api/hotspot/"
			
			findAddress: (coords)->
				$http.get "api/hotspot/findAddress", {params: coords} 
					.then (res) ->
						ret = res.data
					.catch alert		
			
		class MapList extends pageableAR.Collection
			model: geoHotspot
			
			$urlRoot: "api/hotspot/search"

		User:		User
		Tag:	Tag
		Hotspot:	Hotspot
		HotspotList:	HotspotList
		MapList:	MapList
		geoHotspot:	geoHotspot
