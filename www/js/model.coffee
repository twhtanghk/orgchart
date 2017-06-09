{ select } = require 'redux-saga/effects'
require 'regenerator-runtime/runtime'
{ API } = require 'redux-saga-rest'

bfs = (root, cb) ->
 root = cb root
 root.subordinates = root.subordinates?.map (node) ->
   bfs node, cb
 root

auth = ->
  while true
    auth = yield select (state) ->
      state.auth

    if auth.error?
      yeild put type: 'error', error: auth.error
    else if auth.token?
      yield token
    else
      yield put type: 'login'

authMiddleware = -> (req, next) ->
  headers = req.headers || new Headers()

  if req.method == 'PUT'
    token = yield call auth
    headers.set 'Authorization', "Bearer #{token}"

  res = yield next new Request(req, { headers })
  if res.status == 401
    yield put type: 'logout'

  res

module.exports = new API "#{location.href}/api"
  .use authMiddleware()
