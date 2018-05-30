assert = require 'assert'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

[
  'ADMIN'
].map (name) ->
  assert name of process.env, "process.env.#{name} not yet defined"

module.exports = (req, res, next) ->
  email = req.param 'email'
  admin = process.env.ADMIN.split ','

  # check if authenticated user is admin or the same user to be updated
  if req.user.email in admin or email == req.user.email
    return next()

  res.forbidden()
