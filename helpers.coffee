distance = (a, b) ->
  sq = (x) ->
    x * x
  Math.sqrt sq(a.lat - b.lat) + sq(a.lng - b.lng)

random = ->
  r = Math.random() - 0.5
  if r < 0 then r - 0.2 else r + 0.2

randomize = (x) ->
  x + 0.02 * random()



zeropad2 = (x) ->
  x = String(x)
  if x.length == 2 then x else '0' + x