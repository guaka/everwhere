// Set up a collection to contain player information. On the server,
// it is backed by a MongoDB collection named "players."






// On server startup, create some players if the database is empty.
if (Meteor.isServer) {
    Players = new Meteor.Collection("players");
    Meteor.startup(function () {

        Meteor.publish("players", function () {
            // Only 50 "Items" have enabled set to true
            return Players.find({});
        });
    });
}
