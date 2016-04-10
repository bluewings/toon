'use strict'

angular.module 'scomp'
.directive 'scpTableOfContents', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/table-of-contents.directive.html'
  scope:
    _refId: '@refId'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $rootScope, $document, $element, $window, $timeout, apiSpec, global) ->
    vm = @

    vm.app = global.app

    $scope.$watch 'vm.app.header.top', (top) ->
      if typeof top is 'number'
        vm.offsetTop = ($element[0].getBoundingClientRect().top + $($window).scrollTop() - top) * -1
      return

    body = $($document[0].body)

    vm.contents = []

    checkContent = ->
      if vm._refId
        vm.contents = []
        $timeout ->
          vm.contents = []
          headings = body.find("##{vm._refId}").find('h2, h3, h4, h5, h6')
          headings.each (index, item) ->
            each = 
              depth: parseInt(item.tagName.replace(/[^0-9]/g, ''), 10) - 2
              title: $(item).text()
            each.padding = '_______'.substr(0, each.depth * 2)
            vm.contents.push each
            



            # console.log item

            return

          return

        , 200
      return

    $scope.$watch 'vm._refId', (refId) ->
      if refId
        checkContent()
      return

    unbinds = []

    unbinds.push $rootScope.$on '$stateChangeSuccess', checkContent

    $scope.$on '$destroy', ->
      for unbind in unbinds
        unbind()
      return

    return
