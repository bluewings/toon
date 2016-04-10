'use strict'

hashCode = (str) ->
  hash = 0
  if typeof str == 'object' and str != null
    str = JSON.stringify(str)
  if str.length == 0
    return hash
  i = 0
  len = str.length
  while i < len
    chr = str.charCodeAt(i)
    hash = (hash << 5) - hash + chr
    hash |= 0
    i++
  base16 = hash.toString(16).replace(/[^a-z0-9]/g, '')
  base36 = hash.toString(36).replace(/[^a-z0-9]/g, '')
  hash = (parseInt(base16.substr(0, 1), 16) + 10).toString(36) + base36
  hash

angular.module 'scomp'
.factory 'templateIdentifyInterceptor', ($rootScope, $q, $cookieStore, $location, config) ->

  response: (response) ->
    if response.config and response.config.method and response.config.url and response.data
      matches = response.config.url.match(/app\/([^\/]+).*?([^\/]+)\.([a-z]+)$/)
      if matches and matches.length > 3
        if matches[3] is 'html'
          modulePath = response.config.url.replace(/^app\//, '').replace(/\.[a-zA-Z0-9]+$/, '') 
          hash = hashCode(modulePath)
          # 템플릿 추정할 수 있도록 추노 마크를 단다.
          response.data = response.data.replace(/^(\s*<[a-z]+)/, '$1 class=\'' + hash + '\' ')
    response