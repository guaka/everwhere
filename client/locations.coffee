#
# (c) 2012 Kasper Souren
#

# global scope for map
map = null



putMarkers = (p) ->
  p.map (val) ->
    # console.log val.latlng, val.name, val.message
    marker = L.marker(val.latlng, {}).addTo(map)
    marker.bindPopup(val.name + ': ' + val.message)



csIcon = (c) ->
      L.icon(
        iconUrl: c.img
        iconSize: [ c.imgx, c.imgy ] # size of the icon
        iconAnchor: [ c.imgx * .5, c.imgy ] # point of the icon which will correspond to marker's location
        popupAnchor: [-3, -76] # point from which the popup should open relative to the iconAnchor
      )

fbIcon = (c) ->
      L.icon(
        iconUrl: 'https://graph.facebook.com/' + c.uid + '/picture'
        iconSize: [ 50, 50 ] # size of the icon
        iconAnchor: [ 25, 25 ] # point of the icon which will correspond to marker's location
        popupAnchor: [ 0, -25 ] # point from which the popup should open relative to the iconAnchor
      )




class EverMap
  constructor: ->
    @map = L.map("map",
      zoom: 4
      center: [51.5, -0.09]
      minZoom: 2
      maxZoom: 12
    )
    L.tileLayer("http://{s}.tile.cloudmade.com/9c9b2bf2a30e47bcab503fa46901de36/997/256/{z}/{x}/{y}.png",
      attribution: "Map data &copy; <a href=\"http://openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://cloudmade.com/\">CloudMade</a>"
      maxZoom: 12
    ).addTo @map

  setCurrentPosition: ->
    navigator.geolocation.getCurrentPosition (location) =>
      lng = location.coords.longitude
      lat = location.coords.latitude
      Session.set('latlng', [ lat, lng ])
      @map.setView([ lat, lng ], 7)


Meteor.startup ->
  evermap = new EverMap
  evermap.setCurrentPosition()
  map = evermap.map

  Meteor.subscribe 'connections', ->  # CS connections
    # console.log Connections
    Connections.find({}).map (c) ->
      marker = L.marker(c.latlng, if c.img then { icon: csIcon(c) } else {}).addTo map
      # marker = L.marker(c.latlng, {}).addTo map
      text = '<a target="_blank" href="http://www.couchsurfing.org/profile.html?id=' + c.uid + '">' + c.name + '</a>'
      marker.bindPopup text

  add_fb_location = (c, description) ->
    l = c[description]
    if l? and l.latlng?
      marker = L.marker(l.latlng, { icon: fbIcon(c) }).addTo map
      text = '<a target="_blank" href="http://www.facebook.com/profile.php?id=' + c.uid + '">' + c.name + '</a><br />' +
              description.replace('_location', '')
      marker.bindPopup text

  Meteor.subscribe "fbconnections", ->
    f = FbConnections.findOne({})
    if f
      _.map f.data, (c) ->
        add_fb_location c, 'current_location'
        if c.hometown_location? and c.current_location and
           c.hometown_location.latlng != c.current_location.latlng
          add_fb_location c, 'hometown_location'
