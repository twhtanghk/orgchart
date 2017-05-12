module.exports = 
  hookTimeout: 50000
  http:
    middleware:
      order: [
        'bodyParser'
        'compress'
        'methodOverride'
        'router'
        'www'
        'favicon'
        '404'
        '500'
      ]
