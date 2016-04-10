'use strict'

angular.module 'scomp'
# .controller 'ApiSpecImportModalController', ($scope, $modalInstance, $translate, nccCampaign, NccCampaign) ->
.controller 'ApiSpecImportModalController', ($scope, $http, $uibModalInstance, swaggerFile) ->

  isArray = angular.isArray
  isObject = angular.isObject

  getType = (target) ->
    if target is null
      return 'null'
    else if angular.isArray target
      return 'array'
    else if angular.isObject target
      return 'object'
    typeof target

  vm = @

  vm.swaggerFile = swaggerFile

  vm.loadFile = ->
    $http.get vm.swaggerFile
    .success (jsonData) ->
      if typeof jsonData is 'object'
        jsonData = JSON.stringify(jsonData, null, 2)
      vm.jsonData = jsonData
      return
    return

  vm.confirm = ->
    if vm.validJsonObject()
      $uibModalInstance.close(vm.jsonObject)
    return

  vm.validJsonObject = ->
    if vm.info and vm.info.allowedVersion and vm.info.paths is 'object' and vm.info.definitions is 'object'
      return true
    false

  vm.cancel = ->
    $uibModalInstance.dismiss()
    return

  $scope.$watch 'vm.jsonData', (jsonData) ->
    try
      jsonObject = jsyaml.load jsonData
    unless jsonObject
      try
        jsonObject = JSON.parse jsonData
      unless jsonObject
        jsonObject = {}
    vm.jsonObject = jsonObject
    vm.info = 
      version: jsonObject.swagger or 'unknown'
      paths: getType(jsonObject.paths)
      definitions: getType(jsonObject.definitions)
    vm.info.allowedVersion = if vm.info.version.search(/^2\./) isnt -1 then true else false
    return



  return