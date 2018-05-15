module.exports =
  datastores:
    default:
      adapter: require 'sails-mongo'
      url: process.env.DB || 'mongodb://mongo:27017/orgchart'
