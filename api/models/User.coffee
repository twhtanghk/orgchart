module.exports =
  
  tableName:  'user'

  autoPK: false
  
  schema: true
  
  attributes:

    email:
      type: 'string'
      primaryKey: true

    supervisor:
      model: 'user'

    subordinates:
      collection: 'user'
      via: 'supervisor'
