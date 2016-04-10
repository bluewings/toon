'use strict'

angular.module 'scomp'
.filter 'hideQueries', ->
  (value) ->
    value.replace /\{\?[a-zA-Z0-9\_\,]+\}$/g, ''