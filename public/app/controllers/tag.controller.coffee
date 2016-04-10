'use strict'

angular.module 'scomp'
.controller 'ApiTagController', ($scope, markdown, tag) ->
  vm = @

  vm.tag = tag

  vm.markdownOptions =
    markdownId: "tags.#{ tag.name }"
    context: tag
    markdown: markdown

  return