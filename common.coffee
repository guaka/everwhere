FbConnections = new Meteor.Collection('fbconnections')
Connections = new Meteor.Collection("connections")

if Meteor.is_client
  Meteor.startup ->
    console.log('started')