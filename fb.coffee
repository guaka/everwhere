


if Meteor.is_server
  Meteor.publish "accessToken", ->
    user = Meteor.users.findOne(this.userId)
    fb_auth = user.services.facebook
    # fb_fetch fb_auth
    # Meteor.users.find(this.UserId).fetch()



if Meteor.is_client
  # Client needs to subscribe to something for server to do something with userId
  Meteor.subscribe "accessToken", ->



fb_fetch = (auth_fb) ->
  FB.setAccessToken auth_fb.accessToken
  FB.api
    method: "fql.query"
    query: "SELECT uid, name, hometown_location, current_location FROM user WHERE uid IN " + "(SELECT uid2 FROM friend WHERE uid1=" + auth_fb.id + ")"
  , (data) ->
    console.log data
    # _.map data, (o) ->
    #   console.log o.uid

