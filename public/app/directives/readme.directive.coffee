'use strict'

angular.module 'scomp'
.directive 'scpReadme', ($rootScope, $document, $compile, global) ->

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
  controller: ($scope, $element, $compile, $http, apiSpec, scpReadme, global) ->
    vm = @

    vm.local = global.local

    childScope = $scope.$new()

    $http.get 'app/templates/test.md'
    .success (template) ->
      # console.log template
      console.log '%c=============', 'background-color:orange'
      
      template = template.replace /\[([a-zA-Z0-9]+)\s*:\s*([a-zA-Z0-9\_\.]+)\]/g, '<scp-widget-$1 $1="$2"></scp-widget-$1>'
      console.log template
      templateFn = Handlebars.compile template
      # console.log templateFn
      html = templateFn {
        pathVariables: {}
        queries: 'aaa'
        requestBody: ['aaa']
      }
      console.log '%c=============', 'background-color:yellow'
      console.log html

      childScope.pathVariables = {}
      childScope.queries = 'aaa'
      childScope.requestBody = ['aaa']

      html = marked html

      transclude = $compile(html)(childScope)

      $element.find('[transclude]').append transclude

      # transclude($scope)

      return

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
        scpReadme.get readmeId
        .then (readme) ->
          vm.data = readme
          return
      return

    vm.update = ->

      scpReadme.update vm.editData
      .then (data) ->
        # console.log 'done?'
        scpReadme.get vm._readmeId, true
        .then (readme) ->
          vm.data = readme
          return
        vm.edit.disable()
        return
      return



    return
