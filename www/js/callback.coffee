_ = require 'lodash'
queryString = require 'query-string'

window.onload = ->
  search = queryString.parse location.search
  hash = queryString.parse location.hash
  window.parent.postMessage auth: _.extend(search, hash), location.origin
