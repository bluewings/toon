'use strict'

angular.module 'scomp'
.service 'markdownContent', ($q, $http, config, global) ->

  markdowns = {}

  query = (forced = false) ->
    deferred = $q.defer()
    langTag = global.app.langTag

    if !forced and markdowns[langTag]
      deferred.resolve markdowns[langTag]
    else
      $http.get "/markdown-content?langTag=#{langTag}"
      .then (response) ->
        markdowns[langTag] = response.data
        deferred.resolve markdowns[langTag]
        return
      , (err) ->
        deferred.reject err
        return

    deferred.promise

  get = (id, forced = false) ->
    deferred = $q.defer()

    query(forced).then (markdowns) ->
      found = _.find markdowns, { id: id }
      unless found
        found =
          id: id
          content: ''
      deferred.resolve found
      return
    , (err) ->
      deferred.reject err
      return

    deferred.promise

  update = (data) ->
    deferred = $q.defer()

    langTag = global.app.langTag

    $http.put "/markdown-content?langTag=#{langTag}", [data]
    .then (response) ->
      markdowns = response.data
      deferred.resolve markdowns
      return
    , (err) ->
      deferred.reject err
      return

    deferred.promise

  query: query
  get: get
  update: update