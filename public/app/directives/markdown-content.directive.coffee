'use strict'

angular.module 'scomp'
.directive 'scpMarkdownContent', ($rootScope, $document, $compile, global) ->

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
  templateUrl: 'app/directives/markdown-content.directive.html'
  scope:
    _markdownOptions: '=markdownOptions'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $element, $compile, $translate, $http, languages, apiSpec, markdownContent, global) ->
    vm = @

    vm.app = global.app

    vm.languages = languages

    vm.changeLanguage = (language) ->
      $translate.use language
      return

    vm.local = global.local

    childScope = $scope.$new()

    $scope.$watch 'vm._markdownOptions.markdownId', ->

    $scope.$watch 'vm.app.langTag', (langTag) ->
      # console.log '%c' + langTag, 'background-color:blue;color:#fff;font-size:20px'

      vm._markdownOptions.markdown.refresh()
      return





    # $scope.$watch 'vm._markdownId', (markdownId) ->


    #   return
    # console.log vm._markdownOptions.markdown

    $scope.$watch 'vm._markdownOptions.markdown.content', (content) ->
      content = $.trim content
      vm.viewContent = if content then content else vm._markdownOptions.markdown.default
      return

    template = vm._markdownOptions.markdown.default



    getTemplateFn = (template) ->
      template = template.replace /\[([a-zA-Z0-9]+)\s*:\s*([a-zA-Z0-9\_\.]+)\]/g, '<scp-widget-$1 $1="$2"></scp-widget-$1>'
      Handlebars.compile template




    if vm._markdownOptions.context
      _.forIn vm._markdownOptions.context, (value, key) ->
        # # console.log key
        if key.search(/^\$/) is -1 and typeof value isnt 'function'
          childScope[key] = value
        return

    $scope.$watch 'vm.viewContent', (content) ->
      if content
        vm.editData.content = content
        templateFn = getTemplateFn content
        html = templateFn childScope
        html = marked html
        transclude = $compile(html)(childScope)
        $element.find('[view-transclude]').empty().append transclude    
      return
    vm.renderPreview = ->
      # console.log '>>>>>'
      content = vm.editData.content
      #   return
      # $scope.$watch 'vm.editData.content', (content) ->
      templateFn = getTemplateFn content
      html = templateFn childScope
      html = marked html
      transclude = $compile(html)(childScope)
      # console.log '>>>'
      # console.log html
      # console.log $element.find('[preview-transclude]').size()
      $element.find('[preview-transclude]').empty().append transclude    
      return

    # console.log '>>>>>>>>>>>>'
    # console.log vm._markdownOptions

    vm.editData =
      id: vm._markdownOptions.markdown.id
      content: ''

    vm.reset = ->

      vm.editData.content = vm._markdownOptions.markdown.default

    vm.reset()
    # return

    # $http.get 'app/templates/test.md'
    # .success (template) ->
    #   # # console.log template
    #   # console.log '%c=============', 'background-color:orange'
      
    #   template = template.replace /\[([a-zA-Z0-9]+)\s*:\s*([a-zA-Z0-9\_\.]+)\]/g, '<scp-widget-$1 $1="$2"></scp-widget-$1>'
    #   # console.log template
    #   templateFn = Handlebars.compile template
    #   # # console.log templateFn
    #   html = templateFn {
    #     pathVariables: {}
    #     queries: 'aaa'
    #     requestBody: ['aaa']
    #   }
    #   # console.log '%c=============', 'background-color:yellow'
    #   # console.log html

    #   childScope.pathVariables = {}
    #   childScope.queries = 'aaa'
    #   childScope.requestBody = ['aaa']

    #   html = marked html

    #   transclude = $compile(html)(childScope)

    #   $element.find('[transclude]').append transclude

    #   # transclude($scope)

    #   return

    vm.edit =
      enabled: false
      enable: ->
        @enabled = true
      disable: ->
        @enabled = false



    $scope.$watch 'vm.edit.enabled', (enabled) ->
      if enabled
        # vm.editData = {
        # angular.extend {}, vm.data
        return
      else
        return
        vm.editData = null
      return



    vm.update = ->

      markdownContent.update vm.editData
      .then (data) ->
        # # console.log 'done?'
        markdownContent.get vm._markdownOptions.markdown.id, true
        .then (markdown) ->

          vm.viewContent = markdown.content

          # console.log markdown
          # vm.data = readme
          return
        vm.edit.disable()
        return
      return



    return
