module.exports = 
  policies:
    UserController:
      '*': false
      find: true
      findOne: ['user/me']
      update: ['isAuth', 'isOwner']
