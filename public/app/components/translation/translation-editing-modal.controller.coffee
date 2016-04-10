'use strict'

angular.module 'scomp'
.controller 'TranslationEditingModalController', ($scope, $uibModalInstance, $http, $translate, langKey, translationId, translation) ->
  vm = @

  vm.langKey = langKey
  vm.translationId = translationId
  vm.translation = translation
  vm._translation = JSON.parse(JSON.stringify(translation))

  vm.dismiss = ->
    $uibModalInstance.dismiss()
    return

  vm.update = ->
    $http.put "/translation/#{translationId}", vm.translation
    .then (response) ->
      $translate.refresh()
      $uibModalInstance.close()
      return
    , (response) ->
      alert response.data
      return
  
  return