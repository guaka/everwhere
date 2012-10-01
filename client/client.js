
Players = new Meteor.Collection("players");

var markers = new OpenLayers.Layer.Markers( "Markers" );
var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984
var toProjection = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection
var zoom = 12;
var size = new OpenLayers.Size(21, 25);
var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
var icon = new OpenLayers.Icon('http://www.openlayers.org/dev/img/marker.png', size, offset);
var map, mapnik;


Template.number.number = function() {
    return $.unique(Players.find({}).map(function (x) { return x.name; } )).length
};

Template.status.status = function() {
    var s = Players.findOne(Session.get('player_id'));
    if (s) return s.message;
};

Template.messages.messages = function() {
    var p = Players.find({}, { sort : { lastSeen: 1 }});
    return p.map(function (i) {
        i.lastSeen = new Date(i.lastSeen);
        i.lastSeen = i.lastSeen.getHours() + ':' + i.lastSeen.getMinutes();
        i.latlng = [ i.latlng[0].toFixed(3), i.latlng[1].toFixed(3) ];
        return i;
    });
}

var getUsername = function() {
    if (Meteor.user()) {
        return Meteor.user().profile.name;
    } else {
        return 'unknown';
    }
}



var updatePlayer = function(s) {
    if (s === undefined) s = $('#input-status')[0].value;
    

    if (s) 
        pid = Players.insert({ message: s, 
                               name: getUsername(),
                               latlng: JSON.parse(Session.get('latlng')), 
                               lastSeen: new Date()
                             });
}



var insertPlayer = function () {
    console.log('insertPlayer');
    updatePlayer('welcome');
    Session.set('player_id', pid);
    $.cookie("player_id", pid);
    return pid;
}



Template.status.events({
    'focusout #input-status': function (evt) {
        console.log(evt.target.value);
        updatePlayer();
    },
    'keyup #input-status': function (evt) {
        if (evt.keyCode == 13) {
            updatePlayer();
            $('#input-status').focus();
            $('#input-status').val('');
            // Make sure new chat messages are visible
            $("#chat").scrollTop(9999999);
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
        console.log(val.player_id + ' ' + Session.get('latlng') + ' ' + val.message);
        console.log('addMarker');
        markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(val.latlng[1], val.latlng[0]).transform(fromProjection, toProjection), icon.clone()));
    });
});



