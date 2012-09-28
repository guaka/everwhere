
Players = new Meteor.Collection("players");


Template.leaderboard.players = function () {
    return Players.find({}, {sort: {player_id: 1}});
};


Template.number.number = function() {
    return Players.find({}).count();
};


Template.status.events({
    'focusout #input-status': function (evt) {
        console.log(evt.target.value);
        Players.update(Session.get('player_id'), { $set: { status: evt.target.value }});
    }
});


var updatePlayer = function() {
    var pid = Session.get('player_id');
    if (Players.find( { player_id: pid } ).count() == 0) {

    } else {
        Players.update(
            pid,
            { $set: { latlng: Session.get('latlng') } }
        );
    }
}

var markers = new OpenLayers.Layer.Markers( "Markers" );
var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984                                                                                     
var toProjection   = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection                                                      
var zoom           = 12;


var size = new OpenLayers.Size(21, 25);
var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
var icon = new OpenLayers.Icon('http://www.openlayers.org/dev/img/marker.png', size, offset);


var map, mapnik;

function GetLocation(location) {
    var lng = location.coords.longitude;
    var lat = location.coords.latitude;
    Session.set('latlng', [ lat, lng ]);
    var position = new OpenLayers.LonLat(lng, lat).transform(fromProjection, toProjection);
    map.setCenter(position, zoom);
    map.addLayer(markers);

    var pid;
    if (!$.cookie("player_id") || Players.find().count() == 0) {
        pid = Players.insert({status: 'Yo', latlng: [ lat, lng], idle: false});
        Session.set('player_id', pid);
        $.cookie("player_id", pid);
    } else {
        pid = $.cookie('player_id');
        Session.set('player_id', pid);
    }
};


Meteor.startup(function () {
    console.log('startup');

    map = new OpenLayers.Map('map');
    mapnik = new OpenLayers.Layer.OSM();
    map.addLayer(mapnik);
    navigator.geolocation.getCurrentPosition(GetLocation);
});

Meteor.autosubscribe(function() {
    Meteor.subscribe('players');
    console.log('autosub');
    
    if (Session.get('latlng') !== undefined)
        updatePlayer();

    Players.find({}).map(function(val) {
        console.log(val.player_id + ' ' + Session.get('latlng') + ' ' + val.status);
        markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(val.latlng[1], val.latlng[0]).transform(fromProjection, toProjection), icon.clone()));
    });
});


