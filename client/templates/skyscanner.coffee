
document.snippet = null


Meteor.startup ->
  console.log 'checking for skyscanner'
  if skyscanner?
    console.log 'skyscanner is here'
    skyscanner.setOnLoadCallback ->
      document.snippet = snippet = new skyscanner.snippets.SearchPanelControl()
      snippet.setCurrency 'USD'
      snippet.setShape 'leaderboard'
      snippet.setDeparture 'br'
      snippet.draw(document.getElementById('snippet_searchpanel'))

