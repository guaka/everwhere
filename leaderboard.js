// Set up a collection to contain player information. On the server,
// it is backed by a MongoDB collection named "players."

Players = new Meteor.Collection("players");

if (Meteor.isClient) {
  Template.leaderboard.players = function () {
    return Players.find({}, {sort: {score: -1, name: 1}});
  };

  Template.leaderboard.selected_name = function () {
    var player = Players.findOne(Session.get("selected_player"));
    return player && player.name;
  };

  Template.player.selected = function () {
    return Session.equals("selected_player", this._id) ? "selected" : '';
  };

  Template.leaderboard.events({
    'click input.inc': function () {
      Players.update(Session.get("selected_player"), {$inc: {score: 5}});
    }
  });

  Template.player.events({
    'click': function () {
      Session.set("selected_player", this._id);
    }
  });


    var somewhat_uuid = function() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });
    }
    
    var delete_cookie = function() {
        document.cookie =  'id=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    }

    Meteor.startup(function () {

        var uuid;
        if (!document.cookie.match("id")) {
            uuid = somewhat_uuid();
            document.cookie = "id=" + uuid + ";expires=Sat, 23 Mar 2013 00:00:0 GMT";    
        } else {
            uuid = document.cookie.replace('id=', '');
        }

        var map = new OpenLayers.Map('map');
        var mapnik         = new OpenLayers.Layer.OSM();
        map.addLayer(mapnik);
        
        var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984                                                                                     
        var toProjection   = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection                                                      
        var zoom           = 12;

        var random = function() {
            var r = Math.random() - 0.5;
            if (r < 0) {
                r -= 0.5;
            } else {
                r += 0.5;
            }
            return r;
        }
        
        var randomize = function(x) {
            return x + random() * 0.01;
        }
        
        function GetLocation(location) {
            var lng = location.coords.longitude;
            var lat = location.coords.latitude;
            var position = new OpenLayers.LonLat(lng, lat).transform(fromProjection, toProjection);
            map.setCenter(position, zoom);

            var markers = new OpenLayers.Layer.Markers( "Markers" );
            
            var size = new OpenLayers.Size(21, 25);
            var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
            var icon = new OpenLayers.Icon('http://www.openlayers.org/dev/img/marker.png', size, offset);
            
            lat = randomize(lat);
            lng = randomize(lng);
            markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(lng, lat).transform(fromProjection, toProjection),icon));

            Players.insert({name: uuid,
                            lat: lat,
                            lng: lng,
                            session: Session.get()
                           });

            map.addLayer(markers);
        }
        navigator.geolocation.getCurrentPosition(GetLocation);
    });



}

// On server startup, create some players if the database is empty.
if (Meteor.isServer) {
  Meteor.startup(function () {
    if (Players.find().count() === 0) {
      var names = ["Ada Lovelace",
                   "Grace Hopper",
                   "Marie Curie",
                   "Carl Friedrich Gauss",
                   "Nikola Tesla",
                   "Claude Shannon"];
      for (var i = 0; i < names.length; i++)
        Players.insert({name: names[i], 
                        score: Math.floor(Math.random()*10)*5
                       });
    }
  });
}
