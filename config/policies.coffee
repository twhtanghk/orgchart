module.exports = 
	policies:
		UserController:
			'*':		false
			find:		true
			#find:		['isAuth']
			findOne:	['isAuth']
			create:		['isAuth']
			update:		['isAuth']
			destroy:	['isAuth']
			add:		['isAuth']
			remove:		['isAuth']			
			findSuper:	['isAuth', 'user/me']
			updateSuper:	['isAuth', 'user/me']
			deleteSuper:	['isAuth', 'user/me']
			findMe:		['isAuth', 'user/me']
