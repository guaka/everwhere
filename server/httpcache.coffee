#
# (c) 2012 Kasper Souren
#

# httpcache is a http cacher using a queue, for Meteor that deals with
# callbacks


HttpCache = new Meteor.Collection('httpcache')

httpqueue = []

httpdbg = (msg) ->
  # console.log msg

if Meteor.is_server
  Meteor.startup ->
    # Take one request per 1234 ms
    Meteor.setInterval http_processq, 1234


httpcache = (url, callback) ->
  obj = HttpCache.findOne({ url: url })
  if obj
    httpdbg 'Found ' + url + ' in cache'
    if callback then callback obj.content else obj.content
  else
    httpqueue.push { url: url, callback: callback }

http_processq = ->
  if httpqueue.length > 0
    el = httpqueue.pop()
    httpdbg 'Popped ', el, ' from ', httpqueue
    url = el.url
    callback = el.callback
    obj = HttpCache.findOne({ url: url })
    if obj
      httpdbg 'Found ' + url + ' in cache'
      if callback then callback obj.content else obj.content
    else
      httpdbg 'Fetching ' + url
      Meteor.http.get url, (err, res) ->
        httpdbg res
        if res? and res.content?
          callback res.content if callback
          httpdbg 'Storing ' + url + ' in cache'
          HttpCache.insert { url: url, content: res.content }
          res.content



