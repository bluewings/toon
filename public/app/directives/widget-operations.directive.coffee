'use strict'

angular.module 'scomp'
.directive 'scpWidgetOperations', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/widget-operations.directive.html'
  scope:
    _operations: '=operations'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, apiSpec) ->
    vm = @


    return
