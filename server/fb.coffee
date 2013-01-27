#
# (c) 2012 Kasper Souren
#

FqlCache = new Meteor.Collection('fqlcache')


Meteor.startup ->
  Meteor.publish "fbconnections", ->
    if this.userId
      user = Meteor.users.findOne this.userId
      # This will break for logins other than FB
      fb_auth = user.services.facebook
      fb_fetch fb_auth
      return FbConnections.find( uid: fb_auth.id )


fql_cache = (query, callback) ->
  # $exists is slow according to http://www.mongodb.org/display/DOCS/Advanced+Queries#AdvancedQueries-%24exists
  c = FqlCache.findOne( { query: query, "data.error_code" : { $exists : false }} )
  console.log 'in fqlcache:', c
  # TODO: error handling in case of expired FB sessions (quite common)
  if c and !c.data.error_code?
    callback c.data
  else
    FB.api { method: "fql.query", query: query }, (data) ->
      Fiber( ->
        if !data.error_code
          FqlCache.insert { query: query, data: data }
      ).run()
      callback data



fb_fetch = (auth_fb) ->
  FB.setAccessToken auth_fb.accessToken
  # TODO: check if FB can return latlng for locations
  fql_cache "SELECT uid, name, hometown_location, current_location FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=" + auth_fb.id + ")", (data) ->
    Fiber( ->
      _.map data, (e) ->
        if e.hometown_location
          geo = geocode e.hometown_location.name
          e.hometown_location.latlng = if geo then geo.latlng else null
        else if e.current_location
          geo = geocode e.current_location.name
          e.current_location.latlng = if geo then geo.latlng else null

      FbConnections.remove { uid: auth_fb.id }
      FbConnections.insert { uid: auth_fb.id, data: data }
    ).run()