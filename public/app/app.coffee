'use strict'

angular.module 'scomp', [
  'ngSanitize', 'ngResource', 'ngAnimate', 'ngCookies', 'ui.router', 'ui.bootstrap', 
  'jsonFormatter','pascalprecht.translate', 'hc.marked',
  
  # 'ui.bootstrap.tabs',
  # 'mgcrea.jquery'
  'mgcrea.ngStrap'
  # 'mgcrea.bootstrap.affix',

  'hljs'
  'config'
]
.config ($provide, $translateProvider, $httpProvider, $stateProvider, $locationProvider, $urlRouterProvider, config) ->
  searchParams = ->
    params = {}
    items = location.search.replace(/^\?/, '').split('&')
    for item in items
      tmp = item.split('=')
      name = tmp.shift()
      if name
        params[name] = tmp.join('=')
    params

  config.search = searchParams()
  config.debug = true if typeof config.search.debug isnt 'undefined'
  config.tags = {} unless config.tags
  config.definitions = {} unless config.definitions

  $provide.decorator '$state', ($delegate, $rootScope) ->
    $rootScope.$on '$stateChangeStart', (event, state, params) ->
      $delegate.next = state
      $delegate.toParams = params
      return
    $delegate

  getMarkdown = ['$q', '$state', '$stateParams', '$http', 'markdownContent', ($q, $state, $stateParams, $http, markdownContent) ->
    deferred = $q.defer()

    # for key, value of $state
    #   if typeof value isnt 'function'
    #     # console.log key, value
    href = $state.href $state.next, $stateParams
    mdFile = $state.next.templateUrl.replace(/\.html$/, '.md')



    markdownContent.get href, true
    .then (data) ->

    # $state.get 

      $http.get mdFile
      .success (markdown) ->
        # # console.log markdown
        deferred.resolve
          id: data.id
          content: data.content
          default: markdown
          refresh: ->
            my = @
            markdownContent.get href, true
            .then (data) ->

              my.content = data.content
              return

        return
      .error (err) ->
        deferred.resolve ''
        # # console.log err
        return


    # # console.log mdFile
    # .success (markdown) ->
    #   # console.log markdown
    #   return
    # .error (err) ->
    #   return

    # # console.log JSON.parse(JSON.stringify($state.next))


    
    deferred.promise
  ]

  $locationProvider.html5Mode(true)

  $urlRouterProvider.otherwise '/'

  $stateProvider.state 'api',
    abstract: true
    templateUrl: 'app/controllers/wrap.controller.html'
    controller: 'ApiWrapController'
    controllerAs: 'vm'

  $stateProvider.state 'api.main',
    url: '/'
    gnb: 'api'
    parent: 'api'
    templateUrl: 'app/controllers/main.controller.html'
    controller: 'ApiMainController'
    controllerAs: 'vm'
    resolve:
      markdown: getMarkdown

  $stateProvider.state 'api.definitions',
    url: '/definitions'
    gnb: 'api'
    parent: 'api'
    templateUrl: 'app/controllers/definitions.controller.html'
    controller: 'ApiDefinitionsController'
    controllerAs: 'vm'
    resolve:
      markdown: getMarkdown
    # resolve:
    #   definition: ($q, $stateParams, apiSpec) ->
    #     deferred = $q.defer()
    #     apiSpec.getDefinition $stateParams.definition
    #     .then (definition) ->
    #       deferred.resolve definition
    #       return
    #     , (err) ->
    #       deferred.reject err
    #       return
    #     deferred.promise

    #   refs: ($q, $stateParams, apiSpec) ->
    #     deferred = $q.defer()
    #     apiSpec.getReferences()
    #     .then (references) ->
    #       deferred.resolve(references[$stateParams.definition] or {})
    #       return
    #     , (err) ->
    #       deferred.reject err
    #       return
    #     deferred.promise

  $stateProvider.state 'api.definition',
    url: '/definitions/:definition'
    gnb: 'api'
    parent: 'api'
    templateUrl: 'app/controllers/definition.controller.html'
    controller: 'ApiDefinitionController'
    controllerAs: 'vm'
    resolve:
      markdown: getMarkdown

      definition: ($q, $stateParams, apiSpec) ->
        deferred = $q.defer()
        apiSpec.getDefinition $stateParams.definition
        .then (definition) ->
          deferred.resolve definition
          return
        , (err) ->
          deferred.reject err
          return
        deferred.promise

      refs: ($q, $stateParams, apiSpec) ->
        deferred = $q.defer()
        apiSpec.getReferences()
        .then (references) ->
          deferred.resolve(references[$stateParams.definition] or {})
          return
        , (err) ->
          deferred.reject err
          return
        deferred.promise

  $stateProvider.state 'api.tags',
    url: '/tags'
    gnb: 'api'
    parent: 'api'
    templateUrl: 'app/controllers/tags.controller.html'
    controller: 'ApiTagsController'
    controllerAs: 'vm'
    resolve:
      markdown: getMarkdown
    # resolve:
    #   markdown: ->

    # resolve:
    #   tag: ($q, $stateParams, apiSpec) ->
    #     deferred = $q.defer()
    #     apiSpec.getTag $stateParams.tag
    #     .then (tag) ->
    #       deferred.resolve tag
    #       return
    #     , (err) ->
    #       deferred.reject err
    #       return
    #     deferred.promise

  # getMarkdown = ($q, $http, $state, $stateParams) ->


  $stateProvider.state 'api.tag',
    url: '/tags/:tag'
    gnb: 'api'
    parent: 'api'
    templateUrl: 'app/controllers/tag.controller.html'
    controller: 'ApiTagController'
    controllerAs: 'vm'
    resolve:
      markdown: getMarkdown
      tag: ($q, $stateParams, apiSpec) ->
        deferred = $q.defer()
        apiSpec.getTag $stateParams.tag
        .then (tag) ->
          deferred.resolve tag
          return
        , (err) ->
          deferred.reject err
          return
        deferred.promise


  $stateProvider.state 'api.operation',
    url: '/operations/:method/:uri'
    gnb: 'api'
    parent: 'api'
    templateUrl: 'app/controllers/operation.controller.html'
    controller: 'ApiOperationController'
    controllerAs: 'vm'
    resolve:
      markdown: getMarkdown
      operation: ($q, $stateParams, apiSpec) ->
        # console.log decodeURIComponent($stateParams.uri)
        deferred = $q.defer()
        apiSpec.getOperation $stateParams.method, decodeURIComponent($stateParams.uri)
        .then (operation) ->
          # console.log operation
          deferred.resolve operation
          return
        , (err) ->
          deferred.reject err
          return
        deferred.promise

  # for CORS requests
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']

  # http interceptors
  $httpProvider.interceptors.push 'templateIdentifyInterceptor'

  # console.log '>>>>>>>>>>>>'
  # $httpProvider.interceptors.push 'preventCacheInterceptor'
  # $httpProvider.interceptors.push 'xAcceptLanguageInterceptor'
  # $httpProvider.interceptors.push 'xHttpMethodOverrideInterceptor'
  # $httpProvider.interceptors.push 'jwtInterceptor'
  # jwtInterceptorProvider.tokenGetter = ['Auth', (Auth) ->
  #   Auth.tokenGetter()
  # ]

  # 번역 관련 설정
  if config.i18n
    $translateProvider.useStaticFilesLoader config.i18n
  else
    $translateProvider.useStaticFilesLoader({
      prefix: 'assets/i18n/locale-'
      suffix: '.json'
    })
  $translateProvider.useLocalStorage()
  $translateProvider.useInterpolation('translationInterpolation')
  $translateProvider.preferredLanguage('ko-KR')
  $translateProvider.fallbackLanguage('ko-KR')

  # toastrConfig.
  # angular.extend(toastrConfig, {
  #   allowHtml: true
  #   positionClass: 'toast-bottom-right'
  # })

  # for debugging
  # if config.debug
  #   $httpProvider.interceptors.push 'devToolsInterceptor'

  return
# .run ($rootScope, $translate, $state, $window, $document, $timeout, config, global, util, toast, editableOptions) ->  

.run ($rootScope, $translate, templateUtil, translation, global) ->  

  

  templateUtil.init()

  translation.init()


  # jQuery 로 바인딩한 함수를 쉽게 제거할 수 있도록 하는 함수.
  # 사용법은 angular 의 $on 과 같다. 리턴값으로 unbind 함수를 반환
  unless $.fn.$on
    $.fn.$on = (events, handler, execute, trigger) ->
      that = @
      uniq = parseInt(Math.random() * 100000, 10)
      events = events.replace /([^\s])(\s|$)/g, "$1.#{uniq}$2"
      @each ->
        if trigger
          $(this).on events, -> $timeout handler
        else
          $(this).on events, handler
        return
      if execute
        handler {}
      unbind = ->
        that.each ->
          $(this).off events
          return
        return
      return


  return
  body = $($document[0].body)
  if config.search.theme
    themeClass = "theme-#{config.search.theme}"
  else
    themeClass = 'theme-default'
    # themeClass = 'theme-amaretti'

  body.addClass "t#{util.hashCode(themeClass)}"

  if $window.navigator.userAgent.search(/msie|trident/i) isnt -1
    body.addClass 'msie'

  # constant 목록을 global 을 통해서도 참조할 수 있도록 한다.
  unless global.constant
    global.constant = {}

  moduleNames = ['scomp']
  for moduleName in angular.module('scomp').requires
    if moduleName.search(/^scomp\./) isnt -1
      moduleNames.push moduleName

  for moduleName in moduleNames
    for invoked in angular.module(moduleName)._invokeQueue
      if invoked and invoked[1] is 'constant' and invoked[2]
        global.constant[invoked[2][0]] = invoked[2][1]

    # angular.forEach requiredModuleName, (requiredModuleName) ->
    #   module = angular.module(requiredModuleName)

    # # console.log moduleNames
  # setTimeout ->
  #   angular.forEach app.requires, (requiredModuleName) ->
  #     # angular.forEach app.requires, (requiredModuleName) ->
  #     # console.log requiredModuleName


  #     return
  #   angular.forEach app._invokeQueue, (invoked) ->
  #     if invoked and invoked[1] is 'constant' and invoked[2]
  #       # console.log invoked[2][0]
  #     # var requiredMod = angular.module(requiredModuleName)
  #     return 
  # , 1000




  editableOptions.theme = 'bs3'

  $rootScope.language = $translate.use()

  $rootScope.$on '$translateChangeSuccess', (event, data) ->
    $rootScope.language = data.language
    return

  $rootScope.$on '$stateChangeStart', (event, next, toParams, fromState, fromParams) ->
    $rootScope._next = next
    $rootScope._toParams = toParams
    Auth.isLoggedInAsync (loggedIn) ->
      if next.authenticate and not loggedIn
        event.preventDefault()
        Auth.logout ->
          $state.go 'home'
          return

      return

    return

  $rootScope.$on '$stateChangeSuccess', (event, next, toParams, fromState, fromParams) ->
    delete $rootScope._next
    delete $rootScope._toParams
    if toParams.customerId
      $rootScope.customerId = toParams.customerId
    if fromState
      $state._prev =
        state: fromState
        params: fromParams
    return

  $rootScope.$on '$stateChangeError', (event, next, toParams, fromState, fromParams, err) ->
    # static resource 를 못 얻거나, resolve reject 시 발생
    delete $rootScope._next
    delete $rootScope._toParams

    # console.log arguments
    toast.error err
    return

  # 이전상태로 돌아가는 함수 추가
  unless $state.goToPreviousState
    $state.goToPreviousState = ->
      # 이전 항목이 있는 경우, 해당 상태의 값을 기준으로 이동한다.
      # history.back 과 달리 history 가 쌓인다.
      if $state._prev and $state._prev.state and $state._prev.state.name
        $state.go $state._prev.state.name, $state._prev.params
      return

  # update client width / height
  resizeHandler = ->
    $rootScope.clientWidth = document.documentElement.clientWidth
    $rootScope.clientHeight = document.documentElement.clientHeight
    return

  resizeHandler()

  $($window).on 'resize', (event) ->
    $timeout resizeHandler
    return

  # 파일 다운로드 처리를 위한 부분
  body.delegate 'a[link-download]', 'click', (event) ->
    href = $(event.target).attr('href')
    Auth.tokenGetter().then (signupToken) ->
      dwnFrmId = 'dwnFrmId' + Math.floor((Math.random() * 1000000)).toString(36)
      iframe = document.createElement 'iframe'
      iframe.setAttribute('name', dwnFrmId)
      form = document.createElement 'form'
      input = document.createElement 'input'
      form.appendChild input
      form.setAttribute 'method', 'POST'
      form.setAttribute 'target', dwnFrmId
      form.setAttribute 'action', href
      input.setAttribute 'name', 'Authorization'
      input.setAttribute 'value', 'Bearer ' + signupToken
      $(iframe).css('display', 'none')
      $(form).css('display', 'none')

      # IE 는 dom tree 에 붙어있어야지만 서밋이 된다.
      temporary = $('[data-for-temporary]')
      if temporary.size() isnt 1
        temporary = $('<div data-for-temporary="1"></div>')
        body.append temporary

      temporary.append(iframe)
      temporary.append(form)

      form.submit()

      # 1초 뒤 서밋폼 폭파
      setTimeout ->
        $(form).remove()
        return
      , 1000

      # 60초 뒤 iframe 폭파
      setTimeout ->
        $(iframe).remove()
        return
      , 60 * 1000

    event.preventDefault()
    return


  # override alert, confirm, prompt - 개발모드 번역가능 항목 표시에 태그가 포함되어있으므로 alert 류로 출력시 제거한다.
  if config.debug
    overrides = ['alert', 'confirm', 'prompt']
    for name in overrides
      do (name) ->
        original = window[name]
        window[name] = ->
          if arguments.length > 0
            arguments[0] = arguments[0].replace(/<[^>]+>/g, '')
          original.apply @, arguments
        return

  return