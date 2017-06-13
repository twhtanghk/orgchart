{ call, put, take, select } = require 'redux-saga/effects'
require 'regenerator-runtime/runtime'
{ API } = require 'redux-saga-rest'

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
authMiddleware = -> (req, next) ->
  headers = req.headers || new Headers()

  if req.method == 'PUT'
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

module.exports = new API "#{location.href}/api"
  .use authMiddleware()
