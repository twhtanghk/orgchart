module.exports = 
	routes:							
		'GET /api/supervisor':
			controller:		'UserController'
			action:			'findSuper'
		'POST /api/supervisor':
			controller:		'UserController'
			action:			'updateSuper'		