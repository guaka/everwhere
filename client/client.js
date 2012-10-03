
Players = new Meteor.Collection("players");



Template.number.number = function() {
    return _.uniq(Players.find({}).map(function (x) { return x.name; } )).length
};

Template.status.status = function() {
    var s = Players.findOne(Session.get('player_id'));
    if (s) return s.message;
};


Template.messages.messages = function() {
    var p = Players.find({}, { sort : { lastSeen: -1 }});
    return p.map(function (i) {
        i.lastSeen = new Date(i.lastSeen);
        i.lastSeen = zeropad2(i.lastSeen.getHours()) + ':' + zeropad2(i.lastSeen.getMinutes());
        i.latlng = [ i.latlng[0].toFixed(3), i.latlng[1].toFixed(3) ];
        return i;
    });
}

var getUsername = function() {
    var u = Meteor.user();
    if (u) {
        if (u.profile)
            return Meteor.user().profile.name;
        else if (u.emails)
            return u.emails[0].address
    } 
    return 'unknown';
}



var updatePlayer = function(s) {
    if (s === undefined) 
        s = $('#input-status')[0].value;
    
    if (s) 
        return Players.insert({ message: s, 
                                name: getUsername(),
                                latlng: JSON.parse(Session.get('latlng')), 
                                lastSeen: new Date()
                              });
}



var insertPlayer = function () {
    pid = updatePlayer('welcome');
    Session.set('player_id', pid);
    $.cookie("player_id", pid);
    return pid;
}



Template.status.events({
    'keyup #input-status': function (evt) {
        if (evt.keyCode == 13) {
            updatePlayer();
            $('#input-status').focus();
            $('#input-status').val('');
            // Make sure new chat messages are visible
            // $("#chat").scrollTop(9999999);
        }
    }
});

Meteor.startup(function () {
    $(function () {
        // doesn't work yet?
        $('#input-status').focus();
    });
});



Meteor.subscribe('players', function() {
    // console.log('subscribe players');

    // Only do something if we have a location
    if (Session.get('latlng') !== undefined) {

        var pid;
        // If there's no cookie we have to assume there's nothing in mongo
        if (!$.cookie('player_id')) {
            // console.log('cookieinsert');
            pid = insertPlayer();
        } else {
            // console.log('set session from cookie');
            pid = $.cookie('player_id');
            Session.set('player_id', pid);
            
            // And we can check if the record is still there and or update it
            if (Players.find( pid ).count() == 0) {
                // console.log('otherinsert');
                pid = insertPlayer();
            } else {
                Players.update(
                    pid,
                    { $set: { latlng: JSON.parse(Session.get('latlng')) } }
                );
            }
        }
    }

    putMarkers(lastPositions(Players.find({}).map(id)));
});


var lastPositions = function(p) {
    var names = _.pluck(p, 'name')
    names = _.uniq(names);
    
    return _.map(names, function (n) {
        // take the last entry for each name
        return _.last(_.filter(p, function (x) { return x.name == n }));
    });
}


var putMarkers = function(p) {
    p.map(function(val) {
        var lonLat = new OpenLayers.LonLat(val.latlng[1], val.latlng[0]).transform(fromProjection, toProjection);
        var marker = new OpenLayers.Marker(lonLat, icon.clone());
        var feature = new OpenLayers.Feature(markers, lonLat);
        feature.closeBox = true;
        feature.popupClass = OpenLayers.Class(OpenLayers.Popup.AnchoredBubble, {minSize: new OpenLayers.Size(100, 20) } );
        feature.data.popupContentHTML = val.message;
        feature.data.overflow = "hidden";

        var markerClick = function(evt) {
            if (this.popup == null) {
                this.popup = this.createPopup(this.closeBox);
                map.addPopup(this.popup);
                this.popup.show();
            } else {
                this.popup.toggle();
            }
            OpenLayers.Event.stop(evt);
        };
        marker.events.register("mousedown", feature, markerClick);

        marker.feature = feature
        markers.addMarker(marker);
    });
}
