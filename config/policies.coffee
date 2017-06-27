module.exports = 
  policies:
    UserController:
      '*': false
      create: ['isAuth', 'isAdmin']
      find: ['supervisor']
      findOne: ['me']
      update: ['isAuth', 'me', 'canUpdate']
      destroy: ['isAuth', 'me', 'canUpdate']
