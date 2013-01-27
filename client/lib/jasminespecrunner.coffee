
were_testing = -> document.location.pathname.replace(/^\/([^\/]*).*$/, '$1') == 'test'

UUID_PATTERN = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/


jasmine_test = ->
  jasmineEnv = jasmine.getEnv()
  jasmineEnv.updateInterval = 1000

  htmlReporter = new jasmine.HtmlReporter()
  jasmineEnv.addReporter htmlReporter

  # Specfilter doesn't really work with Backbone router, but
  # commenting it out doesn't disable it:
  # jasmineEnv.specFilter = (spec) ->
  #   htmlReporter.specFilter spec

  jasmineEnv.execute()

  Meteor.setTimeout ->
    document.title = 'testing mapsr' # doesn't work
    Router.navigate 'test'
  , 3000
