#
# (c) 2012 Kasper Souren
#




putMarkers = (p) ->
  p.map (val) ->
    # console.log val.latlng, val.name, val.message
    marker = L.marker(val.latlng, {}).addTo(evermap.map)
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
    markers = []
    Meteor.startup =>
      @createMap()

  createMap: ->
    document.markers = @markers = []
    map = @map = L.map("map",
      zoom: 4
      center: [51.5, -0.09]
      minZoom: 2
      maxZoom: 12
    )
    L.tileLayer("http://{s}.tile.cloudmade.com/9c9b2bf2a30e47bcab503fa46901de36/997/256/{z}/{x}/{y}.png",
      attribution: "Map data &copy; <a href=\"http://openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://cloudmade.com/\">CloudMade</a>"
      maxZoom: 12
    ).addTo @map
    @oms = new OverlappingMarkerSpiderfier(@map,
      nearbyDistance: 120
      circleFootSeparation: 60
      spiralLengthStart: 20
      keepSpiderfied: true
    )


    @setCurrentPosition()

    Meteor.subscribe "fbconnections", =>
      console.log this
      @mapMoved null
      @map.on 'moveend', (e) =>
        console.log this
        @mapMoved e

  setCurrentPosition: ->
    navigator.geolocation.getCurrentPosition (location) =>
      lng = location.coords.longitude
      lat = location.coords.latitude
      Session.set('latlng', [ lat, lng ])
      @map.setView([ lat, lng ], 9)


  mapMoved: (e) ->
    console.log 'map moved', e

    f = FbConnections.findOne {}
    if f
      _.map f.data, (c) =>
        @addFbLocation c, 'current_location'
        if c.hometown_location? and c.current_location and
           c.hometown_location.latlng != c.current_location.latlng
          @addFbLocation c, 'hometown_location'
      for m in @markers
        m.on('mouseover', m.openPopup.bind(m))

  addFbLocation: (c, description) ->
    l = c[description]
    bounds = @map.getBounds()
    if l? and l.latlng? and l.latlng[0]? and l.latlng[1]?
      l.latlng = $.map l.latlng, parseFloat # contains crashes on strings
      if bounds.contains(l.latlng)
        marker_id = c.uid + description
        if not _.contains(_.map(@markers, (m) -> m.id), marker_id)
          marker = L.marker(l.latlng, { icon: fbIcon(c) }).addTo @map
          marker.id = marker_id
          text = '<a target="_blank" href="http://www.facebook.com/profile.php?id=' + c.uid + '">' + c.name + '</a><br />' +
                  description.replace('_location', '')
          marker.bindPopup text
          @oms.addMarker marker

          popup = new L.Popup();
          @oms.addListener 'click', (marker) =>
            popup.setContent text  # marker.desc
            popup.setLatLng marker.getLatLng()
            @map.openPopup popup
          @markers.push marker


document.evermap = evermap = new EverMap


Meteor.startup ->

  Meteor.subscribe 'connections', ->  # CS connections
    Connections.find({}).map (c) ->
      if c.latlng[0]? and c.latlng[1]?
        marker = L.marker(c.latlng, if c.img then { icon: csIcon(c) } else {}).addTo evermap.map
        # marker = L.marker(c.latlng, {}).addTo evermap.map
        text = '<a target="_blank" href="http://www.couchsurfing.org/profile.html?id=' + c.uid + '">' + c.name + '</a>'
        marker.bindPopup text
