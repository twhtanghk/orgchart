util = require 'util'
{ call, put, take, select } = require 'redux-saga/effects'
require 'regenerator-runtime/runtime'
{ API } = require 'redux-saga-rest'
{ toastr } = require 'react-redux-toastr'

auth = ->
  while true
    { error, token } = yield select (state) ->
      state.auth

    if error?
      return yield error: error
    else if token?
      return yield token: token
    else
      yield put type: 'login'
      yield take [
        'loginResolve'
        'loginReject'
      ]

###
yield
  error: error
  data: rest api res.json() data
  detail: ressponse object with detail
###
authMiddleware = (req, next) ->
  headers = req.headers || new Headers()

  if req.method in ['POST', 'PUT', 'DELETE']
    { error, token } = yield call auth
    if error?
      return yield error: error
    headers.set 'Authorization', "Bearer #{token}"

  res = yield next new Request(req, { headers })
  ret = detail: res
  try 
    body = yield res.json()
  catch error
    body = res.statusText
    
  return yield Object.assign ret, if res.ok then data: body else error: body

logoutIfDeny = (req, next) ->
  res = yield next req
  if res.error?
    # clear error or token
    # if existing err is access_denied or Unauthorized
    if res.error in ['access_denied', 'Unauthorized']
      yield put type: 'logout'

  return res

error = (req, next) ->
  res = yield next req
  if res.error?
    msg = if typeof res.error.message == 'string' then res.error.message else util.inspect res.error
    toastr.error msg

  return res

# parse res json body and set res.data to {} if error exists
json = (req, next) ->
  res = yield next req
  res.data = if res.ok then yield res.json() else {}

  return res

module.exports = 
  user: 
    new API "#{location.href}/api"
      .use authMiddleware
      .use logoutIfDeny
      .use error
  profile: 
    new API process.env.PROFILEURL
      .use json
