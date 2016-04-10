'use strict'

angular.module 'scomp'
.controller 'ApiDefinitionController', ($scope, $state, markdown, definition, refs, $http, apiSpec) ->
  vm = @

  vm.definition = definition

  vm.refs = refs

  vm.markdownOptions =
    markdownId: "definitions.#{ vm.definition.name }"
    context: definition
    markdown: markdown

  vm.moveToOperation = (operation) ->
    tmp = operation.split /\s+/
    $state.go 'api.operation', { method: tmp[0], uri: tmp[1] }
    return

  vm.getSchemaRef = (value) ->
    ref = ''
    if value and value.items and value.items.$ref
      ref = value.items.$ref.replace(/^#\/definitions\//, '')
    ref



  # $http.get '/assets/json/api-sample.json'
  # .then (response) ->
  #   data = response.data
  #   vm.data = data
  #   vm.paths = data.paths

  #   vm.tags = []

  #   vm.uris = []

  #   _.forIn data.paths, (methods, uri) ->
  #     # console.log value, key
  #     _.forIn methods, (value, method) ->
  #       # console.log method, uri, value
  #       uriInfo = { uri: uri, method: method }
  #       angular.extend uriInfo, value
  #       vm.uris.push uriInfo


  #       return

  #     return




  #   for tag in vm.data.tags
  #     cloned = angular.extend {}, tag
  #     cloned.uris = _.filter vm.uris, (uriInfo) ->
  #       if uriInfo.tags and uriInfo.tags.indexOf(tag.name) isnt -1
  #         return true
  #       false

  #     vm.tags.push cloned



  #   return


  return