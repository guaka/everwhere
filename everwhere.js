// Set up a collection to contain player information. On the server,
// it is backed by a MongoDB collection named "players."





// On server startup, create some players if the database is empty.
if (Meteor.isServer) {
    Players = new Meteor.Collection("players");
    Meteor.startup(function () {
    });
}
