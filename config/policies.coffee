module.exports = 
	policies:
		UserController:
			'*':		false
			find:		true
			findOne:	true
			create:		['isAuth']
			update:		['isAuth']
			destroy:	['isAuth']
			add:		['isAuth']
			remove:		['isAuth']
			findMe:		['isAuth', 'user/me']
