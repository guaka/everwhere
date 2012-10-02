

var dbgPlayers = function() {
    var p = Players.find().map(function (x) { return x });
    console.log(p);
    return p;
}