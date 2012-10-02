

var markers = new OpenLayers.Layer.Markers( "Markers" );
var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984
var toProjection = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection
var zoom = 12;
var size = new OpenLayers.Size(21, 25);
var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
var icon = new OpenLayers.Icon('http://www.openlayers.org/dev/img/marker.png', size, offset);
var map, mapnik;


function GetLocation(location) {
    var lng = randomize(location.coords.longitude);
    var lat = randomize(location.coords.latitude);
    Session.set('latlng', JSON.stringify([ lat, lng ]));
    var position = new OpenLayers.LonLat(lng, lat).transform(fromProjection, toProjection);
    map.setCenter(position, zoom);
    map.addLayer(markers);
};


Meteor.startup(function () {
    // console.log('startup');
    
    map = new OpenLayers.Map('map');
    mapnik = new OpenLayers.Layer.OSM();
    map.addLayer(mapnik);
    navigator.geolocation.getCurrentPosition(GetLocation);
});

