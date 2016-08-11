winston = require('winston')
customLogger = new (winston.Logger)
# A console transport logging debug and above.
customLogger.add winston.transports.Console,
  level: 'debug'
  colorize: true
  stderrLevels: ['error', 'debug', 'info']

module.exports.log =
  custom: customLogger
  level: 'silly'
  inspect: false