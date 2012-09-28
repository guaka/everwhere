distance = (a, b) ->
  sq = (x) ->
    x * x
  Math.sqrt sq(a.lat - b.lat) + sq(a.lng - b.lng)

random = ->
  r = Math.random() - 0.5
  if r < 0 then r - 0.2 else r + 0.2

randomize = (x) ->
  x + random() * 0.02

somewhat_uuid = ->
  "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
    r = Math.random() * 16 | 0
    v = (if c is "x" then r else (r & 0x3 | 0x8))
    v.toString 16

