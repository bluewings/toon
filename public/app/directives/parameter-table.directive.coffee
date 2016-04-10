'use strict'

angular.module 'scomp'
.directive 'apiParameterTable', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/parameter-table.directive.html'
  scope:
    _parameters: '=parameters'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, apiSpec) ->
    vm = @


    return
