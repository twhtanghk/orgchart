Promise = require 'bluebird'

module.exports = 
  bootstrap: (cb) ->
    _.map sails.models, (model, key) ->
      sails.models[key] = Promise.promisifyAll sails.models[key]
    cb()
