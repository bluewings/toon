'use strict'

angular.module 'scomp'
.directive 'textareaDecorator', ($compile) ->
  restrict: 'A'
  # replace: true
  # templateUrl: 'app/directives/treeview.directive.html'
  # scope: true
  # bindToController: true
  # controllerAs: 'vm'
  controller: ($scope, $element, $window, $timeout) ->
    vm = @

    # # console.log '>> SCOPE'
    # # $scope.$watch 'ngModel', (ng)
    # $scope.$watch 'vm.editData.content', (ngModel) ->
    #   # console.log ngModel
    #   return
    styles = null



    $element.wrap '<div></div>'

    wrapper = $element.parent()

    wrapper.css
      position: 'relative'
      overflow: 'hidden'

    mirror = $('<div></div>')
    wrapper.prepend mirror
    $element.css
      position: 'relative'
      background: 'transparent'

    syncStyle = ->
      unless styles
        computedStyle = $window.getComputedStyle $element[0]
        styles = {}
        _.forIn computedStyle, (value, key) ->

          # if key.search(/^[a-zA-Z]/) isnt -1 and typeof value is 'string'
          if key.search(/font|word|padding|border|white|display|width/i) isnt -1
            styles[key] = value
          return   
        styles.overflow = 'visible' 
        styles.color = 'transparent'
        styles.position = 'absolute'
        styles.top = 0
        styles.left = 0
        styles.pointerEvents = 'none'
        styles.zIndex = 0
        mirror.css styles



      return

    highlights = [
      {
        name: 'handlebars'
        pattern: /(\{\{.*?\}\})/g
      }
      {
        name: 'widget'
        pattern: /(\[[a-zA-Z0-9]+:[a-zA-Z0-9\_]+\])/g
      }
    ]

    inspect = (textarea) ->
      syncStyle()
      value = $element[0].value
      value = value.replace(/</g, '&lt;').replace(/>/g, '&gt;')


      for highlight in highlights
        value = value.replace(highlight.pattern, "<span beacon='#{highlight.name}'>$1</span>")
      
      # console.log value

      mirror.html value

      # results = {}
      # mRect = mirror.getBoundingClientRect()
      # mirror.find('span[beacon]').each (index, item) ->
      #   beaconType = $(item).attr('beacon')
      #   unless results[beaconType]
      #     results[beaconType] = []
      #   iRect = item.getBoundingClientRect()
      #   results.

      #   return
      return


    $element.on 'keyup change', (event) ->

      inspect()


      return

    $element.on 'scroll', (event) ->

      scrollTop = $(event.target).scrollTop()

      mirror.css 'top', scrollTop * -1



      return

    $timeout ->

      inspect()
      return

    return

  link: (scope, element, attrs) ->
    # console.log '>>>>>>'
    return