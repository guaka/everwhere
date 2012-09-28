

var distance(a, b) {
    var sq = function (x) { return x*x; }
    return Math.sqrt(sq(a.lat - b.lat) + sq(a.lng - b.lng));
}



var random = function() {
    var r = Math.random() - 0.5;
    if (r < 0) {
        r -= 0.2;
    } else {
        r += 0.2;
    }
    return r;
}

var randomize = function(x) {
    return x + random() * 0.02;
}


var somewhat_uuid = function() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
    });
}

