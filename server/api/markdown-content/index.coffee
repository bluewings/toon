'use strict'

express = require('express')
# glob = require('glob')
fs = require('fs')
# async = require('async')
path = require('path')
_ = require('lodash')

router = express.Router()

allowedLangTags = ['ko-KR', 'en-US']

markdownFile = (langTag = 'ko-KR') ->
  path.join __dirname, '..', '..', '..', 'public', 'assets', 'i18n', 'markdown-' + langTag + '.json'

getReadme = (langTag, callback = ->) ->
  fs.readFile markdownFile(langTag), 'utf8', (err, data) ->

    # console./log err, data
    if err
      data = {}
    else
      try
        data = JSON.parse data
      if typeof data isnt 'object' or data is null
        data = {}
    # console.log data
    callback null, data
    return
  return

updateReadme = (langTag, jsonData, callback = ->) ->
  fs.writeFile markdownFile(langTag), JSON.stringify(jsonData, null, 2), 'utf8', callback
  return

# 설명 조회
router.get '/', (req, res) ->

  langTag = req.query.langTag

  console.log langTag

  if allowedLangTags.indexOf(langTag) is -1
    langTag = allowedLangTags[0]

  getReadme langTag, (err, data) ->

    console.log err, data
    return res.send(500, err) if err
    contents = []
    for id, content of data 
      contents.push
        id: id
        content: content
    res.json contents
    return
  return

# 내용 갱신
router.put '/', (req, res) ->
  body = ''

  langTag = req.query.langTag

  if allowedLangTags.indexOf(langTag) is -1
    langTag = allowedLangTags[0] 

  req.on 'data', (chunk) ->
    body += chunk
    return

  req.on 'end', ->
    try
      body = JSON.parse body
    catch
      body

    try
      body = JSON.parse body
    
    unless body
      body = []

    getReadme langTag, (err, data) ->
      return res.send(500, err) if err

      for each in body
        id = _.trim(each.id)
        content = _.trim(each.content)
        if id
          if content 
            data[id] = content
          else
            delete data[id]
      
      list = []
      for key, value of data
        list.push id: key, content: value

      list = _.sortBy list, 'id'

      sortedMap = {}

      for each in list
        sortedMap[each.id] = each.content

      updateReadme langTag, sortedMap, (err) ->
        return res.send(500, err) if err

        res.json list  
        return 

      return

    return

  return

module.exports = router