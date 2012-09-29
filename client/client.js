
Players = new Meteor.Collection("players");

var markers = new OpenLayers.Layer.Markers( "Markers" );
var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984
var toProjection = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection
var zoom = 12;
var size = new OpenLayers.Size(21, 25);
var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
var icon = new OpenLayers.Icon('http://www.openlayers.org/dev/img/marker.png', size, offset);
var map, mapnik;


Template.leaderboard.players = function () {
    return Players.find({}, { sort: { player_id: 1 }});
};

Template.number.number = function() {
    return Players.find({}).count();
};

Template.status.status = function() {
    var s = Players.findOne(Session.get('player_id'));
    if (s) return s.status;
};


Template.status.events({
    'focusout #input-status': function (evt) {
        console.log(evt.target.value);
        Players.update(Session.get('player_id'), { $set: { status: evt.target.value }});
    },
    'keypress': function (evt) {
        if (evt.keyCode == 13) {
            Players.update(Session.get('player_id'), { $set: { status: $('#input-status')[0].value }});
        }
    }
});





function GetLocation(location) {
    var lng = location.coords.longitude;
    var lat = location.coords.latitude;
    Session.set('latlng', [ lat, lng ]);
    var position = new OpenLayers.LonLat(lng, lat).transform(fromProjection, toProjection);
    map.setCenter(position, zoom);
    map.addLayer(markers);
};


Meteor.startup(function () {
    console.log('startup');

    map = new OpenLayers.Map('map');
    mapnik = new OpenLayers.Layer.OSM();
    map.addLayer(mapnik);
    navigator.geolocation.getCurrentPosition(GetLocation);
});


var insertPlayer = function () {
    pid = Players.insert({status: 'Yo', latlng: Session.get('latlng'), idle: false});
    Session.set('player_id', pid);
    $.cookie("player_id", pid);
    return pid;
}


Meteor.subscribe('players', function() {
    console.log('subscribe players');

    // Only do something if we have a location
    if (Session.get('latlng') !== undefined) {

        var pid;
        // If there's no cookie we have to assume there's nothing in mongo
        if (!$.cookie('player_id')) {
            console.log('cookieinsert');
            pid = insertPlayer();
        } else {
            // If there is a cookie we can set the session
            pid = $.cookie('player_id');
            Session.set('player_id', pid);
            
            // And we can check if the record is still there and or update it
            if (Players.find( pid ).count() == 0) {
                console.log('otherinsert');
                pid = insertPlayer();
            } else {
                Players.update(
                    pid,
                    { $set: { latlng: Session.get('latlng') } }
                );
            }
        }
    }

    Players.find({}).map(function(val) {
        console.log(val.player_id + ' ' + Session.get('latlng') + ' ' + val.status);
        markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(val.latlng[1], val.latlng[0]).transform(fromProjection, toProjection), icon.clone()));
    });
});

// Meteor.autosubscribe(function() {
//    console.log('autosub');
// });


