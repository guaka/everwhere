#
# (c) 2012 Kasper Souren
#

Geocache = new Meteor.Collection("geocache")
Geoqueue = new Meteor.Collection("geoqueue")


parseJSON = JSON.parse

dbggeo = (msg) ->
  # console.log msg


geostatus = ->
  console.log "\nGeoqueue length " + Geoqueue.find({}).count() + "\nGeocache: " + Geocache.find({}).count()


Meteor.startup ->
  geostatus()
  geocache_clean()
  Meteor.setInterval processq, 5000


geocode = (loc, callback) ->
  obj = Geocache.findOne( { names : loc } )
  if obj # cur.count() > 0
    dbggeo 'Location found in cache: ' + loc + ' ' + obj.latlng
    if callback then callback obj
    Geoqueue.remove({ name : loc } )
    obj
  else
    if not Geoqueue.findOne { name: loc }
      Geoqueue.insert { name: loc, tried: [] }







class Geocoder
  query: (name) ->
    className = @.__proto__.constructor.name
    dbggeo "Executing geoquery " + name + ' thru ' + className
    Geoqueue.update  { name: name },  { $push : { tried: className } }


geocache_insert = (obj) ->
  dbggeo "Inserting " + [ obj.names, obj.latlng ]
  _.each obj.names, (name) ->
    Geoqueue.remove({ name: name })
  Geocache.insert obj
  geostatus()


class GeoGoogle extends Geocoder
  query: (name) ->
    super name
    httpcache "http://maps.google.com/maps/geo?q=" + encodeURIComponent(name), (content) ->
      obj = parseJSON content
      if obj and obj.Placemark
        dbggeo 'Googlegeo: ' + obj
        coor = obj.Placemark[0].Point.coordinates
        latlng = [ coor[1], coor[0] ]
        loc = { names: _.uniq( [ name, obj.name ] ), latlng: latlng }
        geocache_insert loc

class GeoNominatim extends Geocoder
  query: (name) ->
    super name
    httpcache 'http://nominatim.openstreetmap.org/search?q=' + encodeURIComponent(name) + '&format=json&limit=1', (content) ->
      obj = parseJSON content
      fine = false
      if obj
        obj0 = obj[0]
        if obj0 and obj0.display_name
          loc = { names: _.uniq([ name, obj0.display_name ]), latlng: [ obj0.lat, obj0.lon ] }
          geocache_insert loc
          fine = true
      if not fine
        dbggeo 'NO WORKY' + obj


class GeoNames extends Geocoder
  url: (name) ->
    'http://api.geonames.org/searchJSON?q=' + encodeURIComponent(name) + '&maxRows=1&style=SHORT&username=everwhere'

  query: (name) ->
    super name
    content = httpcache (@url(name))
    obj = parseJSON content
    if obj
      obj = obj.geonames[0]
      loc = { names: _.uniq([ name, obj.name ]), latlng: [ obj.lat, obj.lng ] }
      geocache_insert loc


geocache_clean = ->
  Geocache.find().map (obj) ->
    dbggeo obj.location_names


geo_services = [ GeoNominatim, GeoGoogle, GeoNames ]

processq = ->
  if Meteor.is_server
    dbggeo 'PROCESSQ'
    obj = Geoqueue.findOne()
    if obj
      dbggeo 'Sending geoquery for ' + obj.name + ' already tried: ' + obj.tried
      geo_services_list = _.map geo_services, (s) -> [ s, s.name ]
      next_attempts = geo_services_list.filter (s) -> !_.contains obj.tried, s[1]
      if next_attempts.length
        next_attempt = next_attempts[0][0]
        dbggeo next_attempt
        g = new next_attempt()
        g.query(obj.name)
      else
        dbggeo 'giving up on ' + obj.name
        Geoqueue.remove({ name: obj.name })

    else
      dbggeo "Queue empty?"
  if Meteor.is_client
    dbggeo "Can't run query from client, TODO: store location to be processed on server"

