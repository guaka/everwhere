#
# (c) 2012 Kasper Souren
#

# Currently not working when deployed, server side jquery only works
# on development.
# Cheerio is the way to go.
#
#
# Main question: how to get CS uid from nickname


Connections = new Meteor.Collection("csconnections")




Meteor.startup ->
  # uid = '57SQUHK' #erga
  # uid = '5F4MCK' #guaka
  # cs_friends uid

  Meteor.publish "csconnections", ->
    if uid?
      Connections.find { from: uid }


cs_friends = (uid) ->
  # Hopefully this will break with CS Ruby ;)
  httpcache 'http://www.couchsurfing.org/profile.html?ajax_action=show_all_friends&id=' + uid, (content) ->
    f_data = parser content
    save_objects f_data, uid



match_or_empty = (s, regexp) ->
  m = s.match(regexp)
  if m? then m[1] else ''

parserow = (el) ->
  $ = cheerio.load()
  f = {}
  f.uid = 0
  f.el = el
  f.html = $(el).html()

  f.name = f.html.match(/class=\"bold\"( rel=\"met( acquaintance)?\")?>([\w+\s+]+)/)
  # console.log f.name?[3]
  f.uid = f.html.match(/data-hover-profile=":(\w{1,12})"/)[1]
  f.country = match_or_empty f.html, /<strong>(\w+)<\/strong>/
  f.friendship = match_or_empty f.html, /Friendship Type: ([\w+\s+]+)/
  f.met = match_or_empty f.html, /(Met) in person/
  f.vouch = match_or_empty f.html, /(vouch)\.html/
  f.verified = match_or_empty f.html, /(verified)-icon/
  stuff = f.html.split(/<br \/>/)[1..]
  f.stuff = stuff
  agegender = stuff[0]?.split(', ')
  f.age = agegender?[0]
  f.gender = agegender?[1]
  cityprovince = stuff[1]?.split(', ')
  f.city = cityprovince?[0]
  f.province = cityprovince?[1]
  f.country = $(stuff[2]).text()
  stuff2 = stuff[3]?.split(/<br clear="all" \/>/)
  # TODO: f.hoststuff = stuff[5]?.split('<sup>')[1..] if stuff[5]?
  f.since = stuff2?[0].replace('Friends since ', '').replace('  ', ' ')
  f.description = $(stuff2?[1]).text()

  f.img = match_or_empty f.html, /(http\:\/\/s3.amazonaws.+jpg)/
  f.imgx = match_or_empty f.html, /jpg\" width=\"(\d+)\"/
  f.imgy = match_or_empty f.html, /height=\"(\d+)\"/
  f


parser = (content) ->
  $ = cheerio.load(content)
  friends = $("td.friends")
  _.map(friends, parserow)


save_objects = (f_data, from_uid) ->
  _.map f_data, (f) ->
    rec = { from: from_uid, uid: f.uid }
    Connections.remove rec
    location = [ f.city, f.province, f.country ].join ", "
    rec =
      from: from_uid
      uid: f.uid
      name: f.name
      since: f.since
      location: location
      img: f.img
      imgx: f.imgx
      imgy: f.imgy

    geo = geocode rec.location
    if geo
      rec.latlng = geo.latlng
    else
      rec.latlng = [ null, null ]
    # console.log "rec", rec
    Connections.insert rec




