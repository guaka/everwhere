
Players = new Meteor.Collection("players")

Template.number.number = ->
  _.uniq(Players.find({}).map((x) ->
    x.name
  )).length


Template.status.status = ->
  s = Players.findOne(Session.get("player_id"))
  s.message  if s


Template.messages.messages = ->
  p = Players.find({},
    sort:
      lastSeen: -1
  )
  p.map (i) ->
    i.lastSeen = new Date(i.lastSeen)
    i.lastSeen = zeropad2(i.lastSeen.getHours()) + ":" + zeropad2(i.lastSeen.getMinutes())
    i.latlng = [i.latlng[0].toFixed(2), i.latlng[1].toFixed(2)]
    i


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
    Players.insert
      message: s
      name: getUsername()
      latlng: Session.get("latlng")
      lastSeen: new Date()


insertPlayer = ->
  pid = updatePlayer() # was "welcome"
  Session.set "player_id", pid
  $.cookie "player_id", pid
  pid


Template.status.events "keyup #input-status": (evt) ->
  if evt.keyCode is 13
    updatePlayer()
    $("#input-status").focus()
    $("#input-status").val ""


Meteor.startup ->
  $ ->
    $("#input-status").focus()  # doesn't work
    window.scrollTo 0, 0  unless window is top


Meteor.subscribe "players", ->
  # console.log('subscribe players');
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
      if Players.find(pid).count() is 0

        # console.log('otherinsert');
        pid = insertPlayer()
      else
        Players.update pid,
          $set:
            latlng: Session.get("latlng")

  putMarkers lastPositions(Players.find({}).map(id))

lastPositions = (p) ->
  _.map _.uniq(_.pluck(p, "name")), (n) ->

    # take the last entry for each unique name
    _.last _.filter(p, (x) ->
      x.name is n
    )
