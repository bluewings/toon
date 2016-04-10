'use strict'

patternMatches = (pattern, data, columns) ->
  for column in columns
    if typeof data[column] is 'string' and data[column].search(pattern) isnt -1
      return true
  false

angular.module 'scomp'
.filter 'scpTreeviewFilter', ->
  (list, patterns) ->
    if patterns and patterns.length > 0
      result = []
      for each in list
        matched = true
        for pattern in patterns
          unless patternMatches(pattern, each, ['name', 'method', 'uri', 'description', 'summary'])
            matched = false
            break
        if matched
          result.push each
      result
    else
      list

.filter 'scpTreeviewDisplayFilter', ->
  (value, patterns) ->
    if patterns and patterns.length > 0
      # console.log patterns
      for pattern in patterns
        value = value.replace pattern, '<span class="hl">$1</span>'
    value

.directive 'scpTreeview', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/treeview.directive.html'
  scope: 
    _type: '@type'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $rootScope, $stateParams, $window, $element, $timeout, apiSpec, koreanUtil, global) ->
    vm = @

    vm.app = global.app

    $scope.$watch 'vm.app.header.top', (top) ->
      if typeof top is 'number'
        vm.offsetTop = ($element[0].getBoundingClientRect().top + $($window).scrollTop() - top) * -1
      return

    resizeHandler = ->
      



    
      # # console.log '>>> scroll detected'
      cHeight = document.documentElement.clientHeight
      affix = $element.find('[bs-affix]')[0]

      offsetTop = affix.getBoundingClientRect().top

      if offsetTop < vm.offsetTop * -1
        offsetTop = vm.offsetTop * -1

      # console.log offsetTop

      vm.treeviewHeight = cHeight - offsetTop - 20

      $(affix).find('.panel-body').css 'max-height', cHeight - offsetTop - $(affix).find('.panel-heading').outerHeight() - 30

      # # console.log affix

      # # console.log affix.getBoundingClientRect().top


      return
    unbinds = []

    unbinds.push $($window).$on('scroll', resizeHandler)

    unbinds.push $($window).$on('resize', resizeHandler)

    $scope.$on '$destroy', ->
      for unbind in unbinds
        unbind()
      return

    $timeout resizeHandler

    vm.query = ''

    vm.opened =
      definitions: false
      tags: false
      tagMap: {}

    apiSpec.getTags().then (tags) ->
      vm.tags = tags
      apiSpec.getDefinitions().then (definitions) ->
        vm.definitions = definitions
        updateTreeview()
        return
      return

    vm.toggleDefinitions = (event) ->
      if vm.opened.definitions
        vm.opened.definitions = false
      else
        vm.opened.definitions = true
      if event
        event.preventDefault()
        event.stopPropagation()
      return

    vm.toggleTags = (event) ->
      if vm.opened.tags
        vm.opened.tags = false
      else
        vm.opened.tags = true
      if event
        event.preventDefault()
        event.stopPropagation()
      return

    vm.toggleTag = (tag, event) ->
      if vm.opened.tagMap[tag.name]
        delete vm.opened.tagMap[tag.name]
      else
        vm.opened.tagMap[tag.name] = true
      if event
        event.preventDefault()
        event.stopPropagation()
      return

    updateTreeview = (stateParams = $stateParams) ->
      if vm.tags and vm.definitions
        vm.stateParams = $stateParams

        # definition
        if stateParams.definition
          vm.selected =
            definition: stateParams.definition
          vm.opened.definitions = true

        # tag
        else if stateParams.tag
          vm.selected =
            tag: stateParams.tag
          vm.opened.tagMap[stateParams.tag] = true
          vm.opened.tags = true

        # operation
        else if stateParams.method and stateParams.uri
          vm.selected =
            method: stateParams.method
            uri: decodeURIComponent(stateParams.uri)
          for tag in vm.tags
            for operation in tag.operations
              if operation.method is vm.selected.method and operation.uri is vm.selected.uri
                vm.opened.tagMap[tag.name] = true
                vm.opened.tags = true
                return

        else
          vm.selected = {}

      return

    unbinds = []

    unbinds.push $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      updateTreeview(toParams)
      return

    $scope.$watch 'vm.query', (query) ->
      vm.patterns = null
      if query and query.length > 1
        terms = query.split(/\s+/)
        vm.patterns = []
        for term in terms
          pattern = koreanUtil.getPatterns term.replace(/\s/g, ''), true
          vm.patterns.push new RegExp('(' + pattern + ')', 'i')
      return

    $scope.$on '$destroy', ->
      for unbind in unbinds
        unbind()
      return

    return
