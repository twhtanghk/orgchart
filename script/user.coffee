###
read lotus notes exported csv file 
and feed the data into orgchart and user profile

usage:
  node_modules/.bin/coffee script/user.coffee < test/data/email.csv
###
_ = require 'lodash'
Promise = require 'bluebird'
req = Promise.promisifyAll require 'needle'
fs = require 'fs'
stream = require 'stream'
Parser = require('csv').parse
oauth2 = require 'oauth2_client'
{ parseOneAddress } = require 'email-addresses'

token = ->
  users =
    id: process.env.USER_ID.split ','
    secret: process.env.USER_SECRET.split ','
  admin = 
    id: users.id[0]
    secret: users.secret[0]
  client =
    id: process.env.PASS_CLIENT_ID
    secret: process.env.PASS_CLIENT_SECRET
  scope = process.env.SCOPE.split ' '
  oauth2
    .token process.env.TOKENURL, client, admin, scope

class Email extends stream.Transform
  @url:
    user: 'localhost:1337/api/user'
    profile: "#{process.env.PROFILEURL}/api/user"

  _transform: (chunk, encoding, cb) ->
    fields = [
      'First Name'
      'Middle Name'
      'Last Name'
      'Department'
      'Job Title'
      'Business Phone'
      'Internet Address'
    ]
    [ input, title, org ] = /([ a-zA-Z0-9]*)(\(*.*)/.exec chunk['Job Title'].trim().replace('Ag.', '').replace('On leave', '')
    data =
      name:
        given: chunk['First Name']
        family: chunk['Last Name']
      organization:
        name: org
      title: title
      email: chunk['Internet Address']
      phone: [
        { type: 'Office', value: chunk['Business Phone'] }
      ]
    Promise
      .try ->
        if data.email == ''
          throw new Error 'email not yet defined'
        _.extend data, 
          username: parseOneAddress(data.email).local
      .then (data) =>
        Promise
          .all [
            @user data
            @profile data
          ]
      .catch (err) ->
        console.error "#{err}: #{JSON.stringify data}"
      .then ->
        cb()

  user: (data) ->
    token()
      .then (token) ->
        req
          .postAsync Email.url.user, data,
            headers:
              Authorization: "Bearer #{token}"
          .then (res) ->
            if res.statusCode == 201
              Promise.resolve()
            else 
              Promise.reject("user: #{res.body.details || res.statusMessage}")

  profile: (data) ->
    token()
      .then (token) ->
        req
          .postAsync Email.url.profile, data,
            headers:
              Authorization: "Bearer #{token}"
          .then (res) ->
            if res.statusCode == 201
              Promise.resolve()
            else
              Promise.reject("profile: #{res.body.details || res.statusMessage}")

resolve = ->
reject = console.error

process.stdin
  .on 'error', reject
  .pipe new Parser columns: true
  .on 'error', reject
  .pipe new Email
    readableObjectMode: true
    writableObjectMode: true
  .on 'error', reject
  .on 'close', resolve
