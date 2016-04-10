'use strict'

angular.module 'scomp'
.service 'translation', ($rootScope, $translate, $document, $uibModal, global) ->

  init: ->
    my = @

    global.app.langTag = $translate.use()

    $rootScope.$on '$translateChangeSuccess', (event, data) ->
      global.app.langTag = data.language
      return

    $($document[0].body).delegate '.translated-item', 'click', (event) ->
      if global.local._translate
        classes = event.currentTarget.className.split /\s+/
        # 커스텀 어트리뷰트는 sanitizer 에 의해 제거되어 클래스로 옮김
        for each in classes
          if each.search(/^trans-/) isnt -1
            translationId = each.replace /^trans-/, ''
            console.log translationId
            my.modal translationId
            break
        event.stopPropagation()
        event.preventDefault()
        return false
      return

    # add stylesheet
    head = document.head or document.getElementsByTagName('head')[0]
    style = document.createElement('style')
    css = '.show-translation .translated-item { background-color: yellow; color: black; }'
    style.type = 'text/css'
    if style.styleSheet
      style.styleSheet.cssText = css
    else
      style.appendChild document.createTextNode(css)
    head.appendChild style

    # show translate mode
    $rootScope._translation = global.local
    $rootScope.$watch '_translation._translate', (translate) ->
      body = $($document[0].body)
      if translate
        body.addClass 'show-translation'
      else
        body.removeClass 'show-translation'
      return

    # init once only
    @init = ->

    return

  modal: (translationId) ->
    $uibModal.open
      templateUrl: 'app/components/translation/translation-editing-modal.controller.html'
      size: 'md'
      windowClass: 'translation-editing-modal-controller'
      controller: 'TranslationEditingModalController'
      controllerAs: 'vm'
      bindToController: true
      resolve:
        langKey: ($translate) ->
          $translate.use()

        translationId: ->
          translationId

        translation: ($q, $http) ->
          deferred = $q.defer()
          $http.get "/translation/#{translationId}"
          .then (response) ->
            deferred.resolve response.data
          , (err) ->
            deferred.reject err
          deferred.promise

