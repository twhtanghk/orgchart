if not ('ADMIN' of process.env)
  throw new Error "process.env.ADMIN not yet defined"

module.exports = (req, res, next) ->
  # check if authenticated user is admin
  admin = process.env.ADMIN.split ','
  if req.user.email in admin
    return next()

  # check if authenticated user is owner
  req.options.where = req.options.where || {}
  _.extend req.options.where, createdBy: req.user
  next()
