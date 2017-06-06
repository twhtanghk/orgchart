module.exports =
  auth: (state, action) ->
    switch action.type
      when 'login'
        visible: true
        token: null
      when 'loginReject'
        visible: false
        token: null
      when 'loginResolve'
        visible: false
        token: action.token
      when 'logout'
        visible: false
        token: null
      else
        state || { visible: false, token: null }
