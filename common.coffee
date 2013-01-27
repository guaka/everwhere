FbConnections = new Meteor.Collection('fbconnections')
Connections = new Meteor.Collection("connections")

Meteor.startup ->
  console.log('startup!')