module.exports = 
	routes:							
		'GET /api/supervisor':
			controller:		'UserController'
			action:			'findSuper'
		'POST /api/supervisor':
			controller:		'UserController'
			action:			'updateSuper'
		'DELETE /api/supervisor':
			controller:		'UserController'
			action:			'deleteSuper'
		'GET /api/user/me':
			controller:		'UserController'
			action:			'findMe'					