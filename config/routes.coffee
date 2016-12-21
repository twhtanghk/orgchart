module.exports = 
	routes:				
		'GET /api/oauth2/user':
			controller:		'UserController'
			action:			'findOauth2User'
			
		'GET /api/pageable/user':
			controller:		'UserController'
			action:			'findPageableUser'
			
		'GET /api/admForSelect/user':
			controller:		'UserController'
			action:			'findForSelect'	
			