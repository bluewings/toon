'use strict'

angular.module 'scomp'
.directive 'scpHeader', ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/header.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $state, $window, $element, $translate, $timeout, languages, global, apiSpec) ->
    vm = @

    vm.app = global.app

    vm.local = global.local

    vm.state = $state

    vm.menus = [
      {
        sref: 'api.main'
        translationId: 'COMMON.TERM.MENU.HOME'
        pattern: /^api\.main/
      }
      {
        sref: 'api.definitions'
        translationId: 'COMMON.TERM.MENU.DEFINITIONS'
        pattern: /^api\.definition/
      }
      {
        sref: 'api.tags'
        translationId: 'COMMON.TERM.MENU.TAGS'
        pattern: /^api\.(tag|operation)/
      }
    ]

    vm.translate =
      languages: languages
      changeLanguage: (language) ->
        $translate.use language
        return

    vm.openImportModal = ->
      apiSpec.openImportModal()
      return

    $element.delegate '.dropdown-menu a', 'click', (event) ->
      return if $(event.target).hasClass('translated-item')
      event.stopPropagation()
      return

    $scope.$watch 'vm.state.current', (current) ->
      if current and current.name
        vm.current = null
        for menu in vm.menus
          if current.name.match menu.pattern
            vm.current = menu
            break
      return

    $timeout ->
      vm.headerStyle = _.pick $window.getComputedStyle($element.find('header > .navbar')[0]), (value, prop) ->
        if prop.search(/^(height|margin|border)/) isnt -1 then true else false

      vm.app.header =
        top: $element[0].getBoundingClientRect().top + $($window).scrollTop()

      return

    return