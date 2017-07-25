module.exports = 
  policies:
    UserController:
      '*': false
      create: ['isAuth', 'isAdmin']
      find: ['supervisor']
      findOne: ['me']
      destroy: ['isAuth', 'me', 'canUpdate']
      update: ['isAuth', 'me', 'canUpdate']
      add: ['isAuth', 'me', 'canUpdate']
      remove: ['isAuth', 'me', 'canUpdate']
