'use strict'

angular.module 'scomp'
.controller 'ApiOperationController', ($scope, markdown, operation) ->
  vm = @

  vm.operation = operation


  if vm.operation.responses and vm.operation.responses['200']
    vm.operation.responseBody = vm.operation.responses['200']

  vm.markdownOptions =
    markdownId: "operations.#{ vm.operation.uri }::#{ vm.operation.method }"
    context: operation
    markdown: markdown

  return