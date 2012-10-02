Players = new Meteor.Collection("players")

Meteor.startup ->
  Meteor.publish "players", ->
    Players.find {}, {sort: { lastSeen : 1 }}

