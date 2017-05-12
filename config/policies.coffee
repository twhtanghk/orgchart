module.exports = 
  policies:
    UserController:
      '*': false
      find: true
      findOne: ['me']
      update: ['isAuth', 'me', 'canUpdate']
