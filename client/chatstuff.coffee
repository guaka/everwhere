#
# (c) 2012 Kasper Souren
#


Messages = new Meteor.Collection("messages")

# Template.number.fbfriendnumber = ->
#  if evermap? and evermap.markers?
#    evermap.markers.length # should become reactive



getUsername = ->
  u = Meteor.user()
  if u
    if u.profile
      return Meteor.user().profile.name
    else return u.emails[0].address  if u.emails
  "someone"


updatePlayer = (s) ->
  s = $("#input-status")[0].value  if s is `undefined`
  if s
    Messages.insert
      message: s
      name: getUsername()
      latlng: Session.get("latlng")
      lastSeen: new Date()


insertPlayer = ->
  pid = updatePlayer() # was "welcome"
  Session.set "player_id", pid
  $.cookie "player_id", pid
  pid



Meteor.startup ->
  $ ->
    $("#input-status").focus()  # doesn't work
    window.scrollTo 0, 0  unless window is top


Meteor.subscribe "messages", ->
  # Only do something if we have a location
  if Session.get("latlng") isnt `undefined`
    pid = undefined

    # If there's no cookie we have to assume there's nothing in mongo
    unless $.cookie("player_id")

      # console.log('cookieinsert');
      pid = insertPlayer()
    else

      # console.log('set session from cookie');
      pid = $.cookie("player_id")
      Session.set "player_id", pid

      # And we can check if the record is still there and or update it
      if Messages.find(pid).count() is 0

        # console.log('otherinsert');
        pid = insertPlayer()
      else
        Messages.update pid,
          $set:
            latlng: Session.get("latlng")

  putMarkers lastPositions(Messages.find({}).map(id))


lastPositions = (p) ->
  _.map _.uniq(_.pluck(p, "name")), (n) ->

    # take the last entry for each unique name
    _.last _.filter(p, (x) ->
      x.name is n
    )
