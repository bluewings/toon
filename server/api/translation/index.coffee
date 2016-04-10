'use strict'

express = require('express')
glob = require('glob')
fs = require('fs')
async = require('async')
path = require('path')
_ = require('lodash')
simpleGit = require('simple-git')(path.join(__dirname, '../../../'))

router = express.Router()

# 전체 번역본을 모두 찾는다
getTranslations = (convert, callback = ->) ->

  glob "#{__dirname}/../../../public/assets/i18n/locale*.json", (err, files) ->
    return callback(err) if err
    
    reads = []
    for file in files
      do (file) ->
        reads.push (eachCallback) -> 
          fs.readFile file, 'utf8', (err, data) ->
            return eachCallback(err) if err
            try
              data = JSON.parse data
            catch
              data = {}
            eachCallback(null, {
              lang: file.replace(/^.*\-([a-z]+\-[a-z]+)\.json$/i, '$1')
              data: data
            })
          return

    async.parallel reads, (err, data) ->
      return callback(err) if err
      if convert
        result = {}
        for each in data
          result[each.lang] = each.data
        callback null, result
      else
        callback null, data
    return
  return

pathValue = (object, fullpath, value) ->
  paths = fullpath.split('.')
  current = object
  unless value
    # get path value
    for path in paths
      current = current[path]
      unless current
        return ''
    return current

  # set path value
  for path, i in paths
    unless current
      return
    if i < paths.length - 1
      current = current[path]
    else
      current[path] = value
  return

# 특정노드의 언어별 번역을 찾는다.
getTranslation = (translationId, callback = ->) ->
  getTranslations true, (err, data) ->
    return callback(err) if err
    result = {}
    for langKey, value of data
      if data.hasOwnProperty langKey
        result[langKey] = pathValue(value, translationId)
    callback null, result
    return

  return

# 특정노드의 언어별 번역을 찾는다.
setTranslation = (translationId, transition, callback = ->) ->
  getTranslations false, (err, data) ->
    return callback(err) if err
    writes = []
    for each in data
      if transition[each.lang]
        file = "#{__dirname}/../../../public/assets/i18n/locale-#{each.lang}.json"
        pathValue(each.data, translationId, transition[each.lang])
        jsonData = each.data
        do (file, jsonData) ->
          writes.push (eachCallback) -> 
            fs.writeFile file, JSON.stringify(jsonData, null, 2), 'utf8', (err, data) ->
              return eachCallback(err) if err
              eachCallback(null, {})
            return

    async.parallel writes, (err, data) ->
      return callback(err) if err
      callback null, true
    return

  return

# 다수의 번역을 일괄 반영한다.
setTranslations = (translations, lang, callback = ->) ->
  getTranslations false, (err, data) ->
    return callback(err) if err
    writes = []

    target = _.find data, { lang: lang }
    if target
      for translation in translations
        before = pathValue(target.data, translation.TRANSLATION_ID)
        if before is translation.BEFORE and translation.BEFORE isnt translation.AFTER
          pathValue(target.data, translation.TRANSLATION_ID, translation.AFTER)

      file = "#{__dirname}/../../../public/assets/i18n/locale-#{target.lang}.json" 
      fs.writeFile file, JSON.stringify(target.data, null, 2), 'utf8', (err, data) ->
        return callback(err) if err
        callback(null, {})
      return
    else
      callback(null, {})
  return

# git diff 처리한다.
getDiff = (filepath, callbackFn) ->

  options = []
  
  options.push filepath
  simpleGit.diff options, (err, data) ->
    if err
      if callbackFn
        callbackFn err
      return

    lines = data.split /\n/
    diffs = {}
    diff = null
    for line in lines
      matches = line.match /@@\s+\-([0-9]+),[0-9]+\s+\+([0-9]+),[0-9]\s+@@/

      if matches and matches[1] is matches[2]
        if diff
          for each in diff.deleted
            diffs[each.lineNum] =
              lineNo: each.lineNum
              before: each.text
          for each in diff.added
            if diffs[each.lineNum]
              diffs[each.lineNum].after = each.text
        diff =
          deletedIdx: parseInt(matches[1], 10)
          addedIdx: parseInt(matches[1], 10)
          deleted: []
          added: []
      else if diff
        if line.match /^\-/
          diff.deleted.push
            lineNum: diff.deletedIdx++
            text: line.substr(1)
        else if line.match /^\+/
          diff.added.push
            lineNum: diff.addedIdx++
            text: line.substr(1)
        else
          diff.deletedIdx++
          diff.addedIdx++

    if diff
      for each in diff.deleted
        diffs[each.lineNum] =
          lineNo: each.lineNum
          before: each.text
      for each in diff.added
        if diffs[each.lineNum]
          diffs[each.lineNum].after = each.text

    if callbackFn
      callbackFn null, _.values(diffs)
    return

# json file 에서 변경분을 찾아낸다.
getPathnames = (filepath, callbackFn) ->

  fs.readFile filepath, 'utf8', (err, data) ->
    if err
      if callbackFn
        callbackFn err
      return
    lines = data.split /\n/
    path = {}
    results = []

    for line, i in lines
      lineNo = i + 1
      matches = line.match(/^(\s*)"([^"]+)"/)
      if matches
        indent = matches[1].length
        path[indent] = matches[2]
        for depth, name of path
          if indent < parseInt(depth, 10)
            delete path[depth]
        results.push
          lineNo: lineNo
          pathname: _.values(path).join '.'

    if callbackFn
      callbackFn null, results
    return
  return

getTranslationDiff = (lang, callbackFn) ->

  if typeof callbackFn isnt 'function'
    callbackFn = ->


  i18nFile = "#{__dirname}/../../../public/assets/i18n/locale-#{lang}.json" 

  getValueString = (text) ->
    text = text.replace(/^\s*"[^"]+"\s*:\s*"/, '')
    text = text.replace(/"[,]{0,1}\s*$/, '')
    text

  getDiff i18nFile, (err, diffData) ->
    if err
      callbackFn err
      return

    getPathnames i18nFile, (err, pathnameData) ->
      if err
        callbackFn err
        return

      pathnameData = _.indexBy pathnameData, 'lineNo'

      translationDiffs = []

      for each in diffData
        if pathnameData[each.lineNo]
          translationDiffs.push 
            translationId: pathnameData[each.lineNo].pathname
            before: getValueString each.before
            after: getValueString each.after

      callbackFn null, translationDiffs
      return

    return

# 번역 내용 중 diff 조회
router.get '/diff', (req, res) ->
  getTranslationDiff 'ko-KR', (err, data) ->
    return res.send(500, err) if err
    res.json data
  return

# 번역 내용 조회
router.get '/:id', (req, res) ->
  getTranslation req.params.id, (err, data) ->
    return res.send(500, err) if err
    res.json data
  return

# 번역 내용 갱신
router.put '/:id', (req, res) ->
  body = ''

  req.on 'data', (chunk) ->
    body += chunk
    return

  req.on 'end', ->
    try
      body = JSON.parse body
    catch
      body

    setTranslation req.params.id, body, (err, data) ->
      return res.send(500, err) if err
      res.json data

    return

  return

# 번역 내용 일괄 갱신
router.put '/', (req, res) ->
  body = ''

  req.on 'data', (chunk) ->
    body += chunk
    return

  req.on 'end', ->
    try
      body = JSON.parse body
    catch
      body

    unless body
      body = {}

    translations = body.translations or []
    lang = body.lang or 'ko-KR'

    setTranslations translations, lang, (err) ->
      res.json translations
      return
    
    return

  return

module.exports = router