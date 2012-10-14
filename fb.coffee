FqlCache = new Meteor.Collection('fqlcache')


if Meteor.is_client
  # Client needs to subscribe to something for server to do something with userId
  Meteor.subscribe "accessToken", ->


if Meteor.is_server
  Meteor.publish "accessToken", ->
    user = Meteor.users.findOne(this.userId)
    fb_auth = user.services.facebook
    fb_fetch fb_auth





fql_cache = (query, callback) ->
  console.log 'fql ' + query
  c = FqlCache.findOne query: query
  if c
    console.log 'from cache'
    callback c.data
  else
    console.log 'from FB'
    FB.api { method: "fql.query", query: query }, (data) ->
      Fiber( ->
        FqlCache.insert { query: query, data: data }
      ).run()
      console.log "inserting into FqlCache"
      callback data

fb_fetch = (auth_fb) ->
  FB.setAccessToken auth_fb.accessToken
  fql_cache "SELECT uid, name, hometown_location, current_location FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=" + auth_fb.id + ")", (data) ->
    # console.log data
    _.map data, (o) ->
      console.log o

