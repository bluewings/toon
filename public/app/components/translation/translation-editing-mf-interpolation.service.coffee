'use strict'

angular.module 'scomp'
.factory 'translationEditingMfInterpolation', ($sce, $translateSanitization, $cacheFactory) ->
  TRANSLATE_MF_INTERPOLATION_CACHE = '$translateMessageFormatInterpolation'
  $cache = $cacheFactory.get(TRANSLATE_MF_INTERPOLATION_CACHE)
  $mf = new MessageFormat('en')
  $identifier = 'messageformat'
  if !$cache
    $cache = $cacheFactory(TRANSLATE_MF_INTERPOLATION_CACHE)
  $cache.put 'en', $mf

  setLocale: (locale) ->
    $mf = $cache.get(locale)
    if !$mf
      $mf = new MessageFormat(locale)
      $cache.put locale, $mf
    return

  getInterpolationIdentifier: ->
    $identifier

  useSanitizeValueStrategy: (value) ->
    $translateSanitization.useStrategy value
    this

  interpolate: (string, interpolationParams, translationId) ->
    interpolationParams = interpolationParams or {}
    interpolationParams = $translateSanitization.sanitize(interpolationParams, 'params')
    interpolatedText = $cache.get(string + angular.toJson(interpolationParams))
    # if given string wasn't interpolated yet, we do so now and never have to do it again
    if !interpolatedText
      # Ensure explicit type if possible
      # MessageFormat checks the actual type (i.e. for amount based conditions)
      for key of interpolationParams
        if interpolationParams.hasOwnProperty(key)
          # ensure number
          number = parseInt(interpolationParams[key], 10)
          if angular.isNumber(number) and '' + number == interpolationParams[key]
            interpolationParams[key] = number
      interpolatedText = $mf.compile(string)(interpolationParams)
      interpolatedText = $translateSanitization.sanitize(interpolatedText, 'text')
      $cache.put string + angular.toJson(interpolationParams), interpolatedText

    if !interpolatedText and translationId
      interpolatedText = translationId
    
    if translationId
      interpolatedText = $sce.trustAsHtml("<span class='translated-item' data-translation-id='#{translationId}'>#{interpolatedText}</span>")

    interpolatedText