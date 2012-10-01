
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
    return Players.find({ _id : { $ne : Session.get('player_id') }}, 
                        { sort: { player_id: 1 }});
};

Template.number.number = function() {
    return Players.find({}).count() - 1;
};

Template.status.status = function() {
    var s = Players.findOne(Session.get('player_id'));
    if (s) return s.status;
};


var getUsername = function() {
    if (Meteor.user()) {
        return Meteor.user().profile.name;
    } else {
        return 'unknown';
    }
}



var updatePlayer = function(s) {
    Players.update(Session.get('player_id'), { $set: 
                                               { status: $('#input-status')[0].value,
                                                 name: getUsername(),
                                                 lastSeen: new Date().getTime()
                                               }});
}

var insertPlayer = function () {
    console.log('insertPlayer');
    pid = Players.insert({ status: 'welcome', 
                           latlng: JSON.parse(Session.get('latlng')), 
                           lastSeen: new Date().getTime()
                         });
    Session.set('player_id', pid);
    $.cookie("player_id", pid);
    return pid;
}



Template.status.events({
    'focusout #input-status': function (evt) {
        console.log(evt.target.value);
        updatePlayer();
    },
    'keyup #input': function (evt) {
        if (evt.keyCode == 13) {
            updatePlayer();
            $('#input-status').focus();
        }
    }
});





function GetLocation(location) {
    var lng = randomize(location.coords.longitude);
    var lat = randomize(location.coords.latitude);
    Session.set('latlng', JSON.stringify([ lat, lng ]));
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
            console.log('set session from cookie');
            pid = $.cookie('player_id');
            Session.set('player_id', pid);
            
            // And we can check if the record is still there and or update it
            if (Players.find( pid ).count() == 0) {
                console.log('otherinsert');
                pid = insertPlayer();
            } else {
                Players.update(
                    pid,
                    { $set: { latlng: JSON.parse(Session.get('latlng')) } }
                );
            }
        }
    }

    Players.find({}).map(function(val) {
        console.log(val.player_id + ' ' + Session.get('latlng') + ' ' + val.status);
        console.log('addMarker');
        markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(val.latlng[1], val.latlng[0]).transform(fromProjection, toProjection), icon.clone()));
    });
});



