'use strict'

angular.module 'scomp'
.controller 'ApiDefinitionsController', ($scope, $state, $http, apiSpec, markdown) ->
  vm = @


  vm.markdownOptions =
    context: {}
    markdown: markdown

  return
