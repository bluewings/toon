'use strict'

angular.module 'scomp'
.controller 'ApiTagsController', ($scope, $http, apiSpec, markdown) ->
  vm = @


  vm.markdownOptions =
    context: {}
    markdown: markdown

  return

  vm.tag = tag

  # apiSpec.getTags().then (tags) ->
  #   vm.tags = tags
  #   return

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