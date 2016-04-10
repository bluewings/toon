'use strict'

express = require('express')
jwt = require('jsonwebtoken')

router = express.Router()

router.post '/download', (req, res) ->
  if req.body and req.body.Authorization
    token = req.body.Authorization.replace(/^Bearer\s+/, '')
    decoded = jwt.decode token

  res.set({
    'Content-Type': 'text/plain'
    'Content-Disposition': 'attachment; filename=download-text.txt'
  })

  res.send JSON.stringify({
    requestBody: req.body
    decoded: decoded
  }, null, 2)

  return

module.exports = router