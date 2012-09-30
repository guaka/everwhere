

if (Meteor.isServer) {
    Players = new Meteor.Collection("players");
    Meteor.startup(function () {

        Meteor.publish("players", function () {
            return Players.find({});
        });
    });
}
