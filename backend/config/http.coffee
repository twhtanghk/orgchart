module.exports = 
  hookTimeout: 50000
  http:
    middleware:
      nocache: require('nocache')()
      methodOverride: require('method-override')()
      order: [
        'nocache'
        'bodyParser'
        'compress'
        'methodOverride'
        'router'
        'www'
        'favicon'
      ]
