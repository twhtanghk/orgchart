env = require '../../env.coffee'
req = require 'supertest-as-promised'
oauth2 = require 'oauth2_client'
Promise = require 'bluebird'

describe 'controller', ->