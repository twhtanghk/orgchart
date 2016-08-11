module.exports = 
	policies:
		UserController:
			'*':		true
			find:		['isAuth']
			findSuper:	['isAuth', 'user/supervisor']