FqlCache = new Meteor.Collection('fqlcache')


Meteor.publish "fbconnections", ->
  console.log FbConnections.find({}).count()
  if this.userId
    user = Meteor.users.findOne this.userId
    # this is fine as long as we only have FB logins
    fb_auth = user.services.facebook
    fb_fetch fb_auth
    return FbConnections.find( uid: fb_auth.id )


fql_cache = (query, callback) ->
  c = FqlCache.findOne query: query
  if c
    callback c.data
  else
    FB.api { method: "fql.query", query: query }, (data) ->
      Fiber( ->
        FqlCache.insert { query: query, data: data }
      ).run()
      console.log "inserting into FqlCache"
      callback data

fb_fetch = (auth_fb) ->
  FB.setAccessToken auth_fb.accessToken
  fql_cache "SELECT uid, name, hometown_location, current_location FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=" + auth_fb.id + ")", (data) ->
    FbConnections.insert { uid: auth_fb.id, data: data }
