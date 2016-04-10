'use strict'

angular.module 'scomp'
.directive 'inputComposition', ->
  restrict: 'A'
  controller: ($scope, $element, $timeout) ->
    if $element[0].tagName is 'INPUT' or $element[0].tagName is 'TEXTAREA'
      timer = null
      $element.on 'compositionstart compositionupdate', (event) ->
        $timeout.cancel timer
        my = @
        # compositionstart, compositionupdate 가 함께 일어나는 경우가 있어서 timer 를 둔다.
        timer = $timeout ->
           angular.element(my).triggerHandler('compositionend')
          return
        return
    return