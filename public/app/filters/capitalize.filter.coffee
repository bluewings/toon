'use strict'

angular.module 'scomp'
.filter 'capitalize', ->
  (value) ->
    value.replace /(^|-)[a-z]/g, (value) ->
      value.toUpperCase().replace(/\-/g, '')