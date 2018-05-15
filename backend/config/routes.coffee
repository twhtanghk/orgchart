module.exports = 
  routes:
    'GET /api/user':
      controller: 'user'
      action: 'find'
    'GET /api/user/:id':
      controller: 'user'
      action: 'findOne'
    'POST /api/user':
      controller: 'user'
      action: 'create'
    'DELETE /api/user/:id':
      controller: 'user'
      action: 'destroy'
