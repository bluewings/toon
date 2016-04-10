'use strict'

angular.module 'scomp'
.directive 'jsTranslation', ($timeout) ->
  restrict: 'E'
  replace: true
  transclude: true
  templateUrl: 'app/_dev/components/translation/translation.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $document, $http, $translate, global, translation, config, xlsxUtil) ->
    vm = @

    body = $($document[0].body)
    wrap = body.find('> #wrap')

    vm.local = global.prepare('dev').local

    vm.toggleMode = ->
      vm.local._translate = if vm.local._translate then false else true
      return

    $scope.$watch 'vm.local._translate', (translation) ->
      if translation
        wrap.addClass 'dev-translation'
      else
        wrap.removeClass 'dev-translation'
      return

    body.delegate '.translated-item', 'click', (event) ->
      if vm.local._translate
        classes = event.currentTarget.className.split /\s+/
        # 커스텀 어트리뷰트는 sanitizer 에 의해 제거되어 클래스로 옮김
        for each in classes
          if each.search(/^trans-/) isnt -1
            translationId = each.replace /^trans-/, ''
            translation.modal translationId
            break
        event.stopPropagation()
        event.preventDefault()
        return false
      return

    $scope.$on '$destroy', ->
      body.undelegate '.translated-item', 'click'
      return

    return