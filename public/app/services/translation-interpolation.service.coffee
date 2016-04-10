'use strict'

angular.module 'scomp'
.factory 'translationInterpolation', ($interpolate, $filter, config) ->
  $locale = null

  setLocale: (locale) ->
    $locale = locale
    return

  getInterpolationIdentifier: ->
    ''

  interpolate: (translation, interpolateParams, translationId) ->
    if interpolateParams and typeof interpolateParams is 'object'
      translation = $interpolate(translation)(interpolateParams)
    if !translation and translationId
      translation = translationId
    else if $locale.search(/^ko/i) isnt -1
      translation = $filter('koreanPostposition')(translation)
    if translationId and config.debug
      notranslate = if translation is translationId then 'notranslate' else ''
      translation = "<span class='translated-item #{notranslate} trans-#{translationId}'>#{translation}</span>"
    translation
