

Meteor.startup ->
  map = L.map("map").setView([51.505, -0.09], 2) # London

  setLocation = (location) ->
    lng = location.coords.longitude
    lat = location.coords.latitude
    map.setView([ lat, lng ], 9)
  navigator.geolocation.getCurrentPosition(setLocation)

  L.tileLayer("http://{s}.tile.cloudmade.com/9c9b2bf2a30e47bcab503fa46901de36/997/256/{z}/{x}/{y}.png",
    attribution: "Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://cloudmade.com\">CloudMade</a>"
    maxZoom: 18
  ).addTo map

  # marker = L.marker([51.5, -0.09]).addTo(map)
  console.log map

  Meteor.subscribe 'connections', ->
    console.log Connections
    Connections.find({}).map (c) ->
      console.log c
      greenIcon = L.icon(
        iconUrl: c.img
        shadowUrl: "leaf-shadow.png"
        iconSize: [ c.imgx, c.imgy ] # size of the icon
        # shadowSize: [50, 64] # size of the shadow
        iconAnchor: [ c.imgx * .5, c.imgy ] # point of the icon which will correspond to marker's location
        shadowAnchor: [4, 38] # the same for the shadow
        popupAnchor: [-3, -76] # point from which the popup should open relative to the iconAnchor
      )
      marker = L.marker(c.latlng, {icon: greenIcon}).addTo(map)
      link = '<a target="_blank" href="http://www.couchsurfing.org/profile.html?id=' + c.uid + '">' + c.name + '</a>'
      marker.bindPopup(link);
