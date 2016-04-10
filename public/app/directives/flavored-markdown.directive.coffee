'use strict'

angular.module 'scomp'
.directive 'a2markdownContent', ($rootScope, $document, $compile, global) ->

  init = ->
    # add stylesheet
    head = document.head or document.getElementsByTagName('head')[0]
    style = document.createElement('style')
    css = '.btn-edit-description { display: none; }'
    css += '.edit-description .btn-edit-description { display: inline-block; }'
    style.type = 'text/css'
    if style.styleSheet
      style.styleSheet.cssText = css
    else
      style.appendChild document.createTextNode(css)
    head.appendChild style

    # show translate mode
    $rootScope._scpMarkdownContent = global.local
    $rootScope.$watch '_scpMarkdownContent._editDescription', (editDescription) ->
      body = $($document[0].body)
      if editDescription
        body.addClass 'edit-description'
      else
        body.removeClass 'edit-description'
      return
    return

  init()

  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/readme.directive.html'
  scope:
    _readmeId: '@readmeId'
    _schema: '=schema'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, apiSpec, markdownContent, global) ->
    vm = @

    vm.local = global.local

    vm.edit =
      enabled: false
      enable: ->
        @enabled = true
      disable: ->
        @enabled = false

    $scope.$watch 'vm.edit.enabled', (enabled) ->
      if enabled
        vm.editData = angular.extend {}, vm.data
      else
        vm.editData = null
      return


    $scope.$watch 'vm._readmeId', (readmeId) ->

      if readmeId
        markdownContent.get readmeId
        .then (readme) ->
          vm.data = readme
          return
      return

    vm.update = ->

      markdownContent.update vm.editData
      .then (data) ->
        # console.log 'done?'
        markdownContent.get vm._readmeId, true
        .then (readme) ->
          vm.data = readme
          return
        vm.edit.disable()
        return
      return



    return
