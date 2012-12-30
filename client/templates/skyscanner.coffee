

Meteor.startup ->
  skyscanner.load('snippets', '2') if skyscanner?


skyscannerSetDeparture = (lat, lng) ->
  # url = 'http://ws.geonames.org/countryCode?lat=' + lat.toFixed(2) + '&lng=' + lng.toFixed(2)
  countryCode = nearestCountry lat, lng
  console.log 'set skyscanner snippet to ', countryCode
  if skyscanner?
    skyscanner.setOnLoadCallback ->
      document.snippet = snippet = new skyscanner.snippets.SearchPanelControl()
      snippet.setCurrency 'USD'
      snippet.setShape 'leaderboard'
      snippet.setDeparture countryCode
      snippet.draw(document.getElementById('snippet_searchpanel'))


document.snippet = null

nearestCountry = (lat, lng) ->
  sq = (x) -> x * x
  inv = _.invert(country_codes)
  inv[_.min(country_codes,
            (v) -> sq(lat - v[0]) + sq(lng - v[1]) )]
