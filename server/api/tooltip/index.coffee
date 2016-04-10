'use strict'

express = require('express')
fs = require('fs')
async = require('async')

router = express.Router()

# 특정노드의 언어별 번역을 찾는다.
setTooltip = (tooltipId, option, callback = ->) ->

  file = "#{__dirname}/../../../public/assets/json/tooltip.json"
  fs.readFile file, 'utf8', (err, data) ->
    return callback(err) if err
    try
      jsonData = JSON.parse data
    catch
      jsonData = {}

    if tooltipId and option
      jsonData[tooltipId] = option

    fs.writeFile file, JSON.stringify(jsonData, null, 2), 'utf8', (err, data) ->
      return callback(err) if err
      callback(null, {})
    return

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

    setTooltip req.params.id, body, (err, data) ->
      return res.send(500, err) if err
      res.json data

  return

module.exports = router
