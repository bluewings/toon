'use strict'

preloadTemplates = ['switch-checkbox']

angular.module 'scomp'
# .filter 'nccTemplate', (nccTemplate) ->
#   (templateId, context) ->
#     nccTemplate.render templateId, context

.service 'templateUtil', ($q, $timeout, $filter, $translate, $templateCache, $http) ->

  templates = {}

  getArgs = (_arguments) ->
    args = []
    if _arguments
      for each in _arguments
        args.push each
    args.shift()
    # 메타 정보를 담고 있는 파라미터는 사용자가 넘겨준 파라미터가 아니다. (제거해서 전달)
    if args.length > 0 and args[args.length - 1].data and args[args.length - 1].hash
      args.pop()
    args

  # 번역 지원
  Handlebars.registerHelper 'translate', (context) ->
    if typeof context is 'string'
      context =
        translationId: context
        data: {}
    if context and context.translationId
      $translate.instant(context.translationId, context.data)
    else
      return ''

  # 필터 지원
  Handlebars.registerHelper 'filter', (filterName, values) ->
    filter = $filter(filterName)
    if typeof filter is 'function'
      args = getArgs arguments
      if args.length > 0 and args[args.length - 1] is 'translate'
        translate = true
        args.pop()
      filtered = filter.apply null, args
      if translate
        if typeof filtered is 'string'
          filtered = $translate.instant(filtered)
        else if filtered and typeof filtered.translationId is 'string'
          filtered = $translate.instant(filtered.translationId, filtered.data)
      return filtered
    return ''
    args.join ','

  # 비교
  Handlebars.registerHelper 'is', (a, b, options) ->
    if a is b
      return options.fn @ 
    else
      return options.inverse @

  # 비교
  Handlebars.registerHelper 'isnt', (a, b, options) ->
    if a isnt b
      return options.fn @ 
    else
      return options.inverse @

  _getTemplate = (templateId) ->
    deferred = $q.defer()
    $http.get "app/templates/#{templateId}.template.html",
      cache: $templateCache
    .success (html) ->
      templates[templateId] = Handlebars.compile html
      deferred.resolve templates[templateId]
      return
    .error (err) ->
      deferred.reject(err)
      return
    deferred.promise

  init: ->
    # $templateCache 를 사용하기 위한 timeout
    $timeout ->  
      for templateId in preloadTemplates
        _getTemplate templateId
      return
    return

  get: (templateId) ->
    deferred = $q.defer()
    if templates[templateId]
      deferred.resolve templates[templateId]
    else
      _getTemplate templateId
      .then (template) ->
        deferred.resolve(template)
        return
      , (err) ->
        deferred.reject(err)
        return
    deferred.promise

  render: (templateId, context) ->
    template = @get templateId
    if template
      template context
    else
      ''
