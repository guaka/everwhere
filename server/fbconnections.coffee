FbConnections = new Meteor.Collection('fbconnections')

Meteor.startup ->
  Meteor.publish "fbconnections", ->
    if this.userId
      user = Meteor.users.findOne this.userId
      # This will break for logins other than FB
      fb_auth = user.services.facebook
      fb_fetch fb_auth
      return FbConnections.find( uid: fb_auth.id )
