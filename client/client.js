Players = new Meteor.Collection("players");

Template.leaderboard.players = function () {
    return Players.find({}, {sort: {name: 1}});
};

Template.number.number = function() {
    console.log(lat);
    return Players.find({}).count();
};


Template.status.events({
    'focusout #input-status': function (evt) {
        console.log(evt.target.value);
        Players.update(Session.get('uuid'), { status: evt.target.value });
    }
});


var delete_cookie = function() {
    document.cookie =  'id=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
}


var uuid, lat, lng;

var updatePlayer = function(uuid, lat, lng) {
    lat = randomize(lat);
    lng = randomize(lng);
    
    if (Players.find( { name: uuid } ).count() == 0) {
        Players.insert(
            { name: uuid,  lat: lat, lng: lng, status: 'Noob' },
            { name: uuid }
            // upsert doesn't work yet in Minimongo
        );
    };
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
    lng = location.coords.longitude;
    lat = location.coords.latitude;
    var position = new OpenLayers.LonLat(lng, lat).transform(fromProjection, toProjection);
    map.setCenter(position, zoom);
    
    map.addLayer(markers);
};

Meteor.startup(function () {
    console.log('startup');
    
    if (!document.cookie.match("uuid")) {
        uuid = somewhat_uuid();
        document.cookie = "uuid=" + uuid + ";expires=Sat, 23 Mar 2013 00:00:0 GMT";    
        Session.set('uuid', uuid);
    } else {
        uuid = document.cookie.replace('uuid=', '');
        Session.set('uuid', uuid);
    }
    
    map = new OpenLayers.Map('map');
    mapnik = new OpenLayers.Layer.OSM();
    map.addLayer(mapnik);
    navigator.geolocation.getCurrentPosition(GetLocation);
});

Meteor.autosubscribe(function() {
    console.log('autosub');
    
    if (lat !== undefined)
        updatePlayer(uuid, lat, lng);
    Players.find({}).map(function(val) {
        console.log(val.lat + ' ' + val.lng + ' ' + val.status);
        markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(val.lng, val.lat).transform(fromProjection, toProjection), icon.clone()));
    });
});


