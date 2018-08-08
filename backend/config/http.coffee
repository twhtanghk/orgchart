module.exports = 
  hookTimeout: 50000
  http:
    middleware:
      methodOverride: require('method-override')()
      order: [
        'bodyParser'
        'compress'
        'methodOverride'
        'router'
        'www'
        'favicon'
      ]
