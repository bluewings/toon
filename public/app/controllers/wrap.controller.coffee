'use strict'

angular.module 'scomp'
# .controller 'ApiWrapController', ($scope, $rootScope, $state, $timeout, me, global) ->
.controller 'ApiWrapController', ($scope) ->
  vm = @

  return

  vm.local = global.local

  vm.app = global.app

  vm.app.showAsideLeft = true

  vm.animate = false  

  $timeout ->
    vm.animate = true
  , 500

  syncGnb = ->
    vm.state = $state.current
    if vm.state and (vm.state.gnb is 'ncc' and !vm.local.hideAsideNcc) and !vm.state.hideAside
      vm.app.showAsideLeft = true
    else
      vm.app.showAsideLeft = false

  syncGnb()

  $scope.$watch 'vm.local.hideAsideNcc', syncGnb

  unbind = $rootScope.$on '$stateChangeSuccess', syncGnb

  $scope.$on '$destroy', unbind

  return