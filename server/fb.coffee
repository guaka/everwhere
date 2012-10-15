FqlCache = new Meteor.Collection('fqlcache')


Meteor.startup ->
  Meteor.publish "fbconnections", ->
    if this.userId
      user = Meteor.users.findOne this.userId
      # this is fine as long as we only have FB logins
      fb_auth = user.services.facebook
      fb_fetch fb_auth
      return FbConnections.find( uid: fb_auth.id )


fql_cache = (query, callback) ->
  c = FqlCache.findOne query: query
  if c and !c.data.error_code?
    callback c.data
  else
    FB.api { method: "fql.query", query: query }, (data) ->
      Fiber( ->
        console.log "inserting into FqlCache"
        FqlCache.insert { query: query, data: data }
      ).run()
      callback data



fb_fetch = (auth_fb) ->
  FB.setAccessToken auth_fb.accessToken
  fql_cache "SELECT uid, name, hometown_location, current_location FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=" + auth_fb.id + ")", (data) ->
    Fiber( ->
      _.map data, (e) ->
        if e.hometown_location
          geo = geocode e.hometown_location.name
          #console.log geo
          e.hometown_location.latlng = if geo then geo.latlng else null
        else if e.current_location
          geo = geocode e.current_location.name
          #console.log geo
          e.current_location.latlng = if geo then geo.latlng else null

      FbConnections.remove { uid: auth_fb.id }
      FbConnections.insert { uid: auth_fb.id, data: data }
    ).run()