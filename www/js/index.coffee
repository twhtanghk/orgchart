env = require './env.coffee'

window.oalert = window.alert
window.alert = (err) ->
	window.oalert err.data.error
window.Promise = require 'promise'
window._ = require 'underscore'
window.$ = require 'jquery'
window.$.deparam = require 'jquery-deparam'
if env.isNative()
	window.$.getScript 'cordova.js'
	
require 'ngCordova'
require 'angular-activerecord'
require 'angular-http-auth'
require 'ng-file-upload'
require 'tagDirective'
require 'angular'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-ui-router'
require 'ionic'
require 'sails-auth'
require 'util.auth'
require 'googlemaps-utils'
require 'angular-google-maps'
require './app.coffee'
require './controller.coffee'
require './model.coffee'
require './platform.coffee'
