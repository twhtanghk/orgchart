module.exports = 
  policies:
    UserController:
      '*': false
      find: ['supervisor']
      findOne: ['me']
      update: ['isAuth', 'me', 'canUpdate']
