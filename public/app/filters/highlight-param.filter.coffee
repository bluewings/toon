'use strict'

angular.module 'scomp'
.filter 'highlightParam', ->
  (value) ->
    value.replace /(\{[^\}]+\})/g, '<span class="hl-param">$1</span>'