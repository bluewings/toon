'use strict'

angular.module 'scomp'
.service 'apiSpec', ($q, $http, $uibModal, config) ->

  swaggerJson = config.swaggerJson

  unless swaggerJson
    swaggerJson = '/assets/json/api-sample.json'

  jsonData = null

  cached =
    tags: []
    operations: []
    definitions: []
    refs: {}
    regex: {}

  reset = (jsonObject = null) ->
    jsonData = jsonObject
    cached.tags.splice(0, cached.tags.length)
    cached.operations.splice(0, cached.operations.length)
    cached.definitions.splice(0, cached.definitions.length)
    return

  reset()

  getRegex = (pattern) ->
    if cached.regex[pattern]
      regex = cached.regex[pattern]
    else
      try 
        regex = new RegExp(pattern)
      unless regex
        regex = pattern
      cached[pattern] = regex
    regex

  getJson = ->
    deferred = $q.defer()

    if jsonData
      deferred.resolve jsonData
    else
      $http.get swaggerJson
      .then (response) ->
        jsonData = response.data
        deferred.resolve jsonData
        return
      , (err) ->
        deferred.reject err
        return

    deferred.promise

  getOperations = ->
    deferred = $q.defer()

    if cached.operations and cached.operations.length > 0
      deferred.resolve cached.operations
    else
      getJson().then (jsonData) ->
        cached.operations.splice(0, cached.operations.length)
        _.forIn jsonData.paths, (methods, uri) ->
          _.forIn methods, (value, method) ->
            shortUri = uri.replace(/\{([a-zA-Z0-9]+)Id\}/, '{id}')
            method = method.toUpperCase()
            operation = { uri: uri, shortUri: shortUri, method: method }
            angular.extend operation, value
            if operation.tags
              tags = []
              for tag in operation.tags
                if config.tags.pascalCase
                  tag = tag.replace /[_-]([a-zA-Z0-9])/g, (match, p1) -> p1.toUpperCase()
                  tag = tag.charAt(0).toUpperCase() + tag.slice(1)
                if config.tags.replace
                  for pattern, replacement of config.tags.replace
                    search = getRegex pattern
                    tag = tag.replace search, replacement
                tags.push tag
              operation.tags = tags
            if operation.parameters
              operation.pathVariables = _.filter operation.parameters, { in: 'path' }
              operation.queries = _.filter operation.parameters, { in: 'query' }
              operation.requestBody = _.find operation.parameters, { in: 'body' }
              if operation.requestBody and operation.requestBody.name.search(/s$/) isnt -1
                operation.requestBody.isArray = true
              for parameter in operation.parameters
                if parameter.schema
                  _findReference { type: 'operation', name: method + ' ' + uri }, parameter.schema
            if operation.responses and operation.responses['200'] and operation.responses['200'].schema
              _findReference { type: 'operation', name: method + ' ' + uri }, operation.responses['200'].schema
            cached.operations.push operation
            return
          return
        deferred.resolve cached.operations
        return
      , (err) ->
        deferred.reject err
        return

    deferred.promise

  getOperation = (method, uri) ->
    deferred = $q.defer()

    getOperations().then (operations) ->
      deferred.resolve _.find(operations, { method: method, uri: uri })
      return
    , (err) ->
      deferred.reject err
      return

    deferred.promise

  getTags = ->
    deferred = $q.defer()

    if cached.tags and cached.tags.length > 0
      deferred.resolve cached.tags
    else
      getOperations().then (operations) ->
        tags = {}
        for operation in operations
          if operation.tags
            for tag in operation.tags
              unless tags[tag]
                tags[tag] =
                  name: tag
                  description: tag
                  operations: []
              tags[tag].operations.push operation
        cached.tags.splice(0, cached.tags.length)
        for tag in _.values tags
          cached.tags.push tag
        deferred.resolve cached.tags
        return
      , (err) ->
        deferred.reject err
        return

    deferred.promise

  getTag = (tag) ->

    deferred = $q.defer()

    getTags().then (tags) ->
      deferred.resolve _.find(tags, { name: tag })
      return
    , (err) ->
      deferred.reject err
      return

    deferred.promise

  _findReference = (source, data = {}) ->
    ref = ''
    if data.$ref
      ref = data.$ref
    else if data.items and data.items.$ref
      ref = data.items.$ref
    if ref
      ref = ref.split('/').pop()
      # if config.definitions.replace
      #   for pattern, replacement of config.definitions.replace
      #     search = getRegex pattern
      #     ref = ref.replace search, replacement
      unless cached.refs[ref]
        cached.refs[ref] =
          definitions: []
          operations: []
      if source.type is 'definition'
        if cached.refs[ref].definitions.indexOf(source.name) is -1
          cached.refs[ref].definitions.push source.name
      if source.type is 'operation'
        if cached.refs[ref].operations.indexOf(source.name) is -1
          cached.refs[ref].operations.push source.name
    return

  getReferences = ->
    deferred = $q.defer()

    getDefinitions().then ->

      getOperation().then ->

        deferred.resolve cached.refs
        
        return
      , (err) ->
        deferred.reject err
        return

      return
    , (err) ->
      deferred.reject err
      return

    deferred.promise


  getDefinitions = ->
    deferred = $q.defer()

    if cached.definitions and cached.definitions.length > 0
      deferred.resolve cached.definitions
    else
      getJson().then (jsonData) ->
        cached.definitions.splice(0, cached.definitions.length)
        _.forIn jsonData.definitions, (schema, name) ->
          if name.search(/[^a-zA-Z]/) is -1 or name is 'JsonNode'
            if config.definitions.replace
              for pattern, replacement of config.definitions.replace
                search = getRegex pattern
                name = name.replace search, replacement
            definition = { name: name, schema: schema }
            cached.definitions.push definition
            if definition.schema and definition.schema.properties
              for key, value of definition.schema.properties
                _findReference { type: 'definition', name: name }, value
          return
        deferred.resolve cached.definitions
        return
      , (err) ->
        deferred.reject err
        return

    deferred.promise

  getDefinition = (definition) ->
    deferred = $q.defer()

    definition = definition.replace /^#\/definitions\//, ''

    getDefinitions().then (definitions) ->
      deferred.resolve _.find(definitions, { name: definition })
      return
    , (err) ->
      deferred.reject err
      return

    deferred.promise

  openImportModal = ->
    $uibModal.open
      templateUrl: 'app/services/api-spec-import-modal.controller.html'
      size: 'md'
      windowClass: 'api-spec-import-modal-controller'
      controller: 'ApiSpecImportModalController'
      controllerAs: 'vm'
      bindToController: true
      resolve:
        swaggerFile: ->
          swaggerJson
    .result.then (jsonObject) ->
      # swaggerJson = swaggerFile

      # console.log 
      reset(jsonObject)

      # console.log cached
      getTags()
      # .then (opers) ->
      #   console.log opers
      getDefinitions()

        
    return

  getJson: getJson
  getTags: getTags
  getTag: getTag
  getOperations: getOperations
  getOperation: getOperation
  getDefinitions: getDefinitions
  getDefinition: getDefinition
  getReferences: getReferences
  openImportModal: openImportModal
  