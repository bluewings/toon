'use strict'

angular.module 'scomp'
.factory 'global', ($rootScope, $timeout) ->
  my = @

  keyName = 'scomp-global'

  app = {}

  local = {}

  try
    storedLocal = JSON.parse localStorage.getItem(keyName)
    storedLocal = {} if typeof storedLocal isnt 'object'
  catch
    storedLocal = {}

  for key, value of storedLocal
    if storedLocal.hasOwnProperty key
      local[key] = value

  my.instance =
    app: app
    local: local
    prepare: (nodeName) ->
      unless @local[nodeName]
        @local[nodeName] = {}
      @

  $rootScope._globalInstance = my.instance

  updateTimer = null

  $rootScope.$watch '_globalInstance', (global) ->
    if global
      $timeout.cancel updateTimer
      updateTimer = $timeout ->
        localStorage.setItem(keyName, JSON.stringify(my.instance.local))
      , 100
  , true

  my.instance