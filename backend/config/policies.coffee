module.exports = 
  policies:
    UserController:
      '*': false
      find: true
      findOne: true
      destroy: ['isAuth', 'me', 'canUpdate']
      create: ['isAuth', 'canUpdate']
