'use strict'

express = require('express')
# controller = require('./creative.controller')

router = express.Router()

index = (req, res) ->

  req = {}
  # app.use '/demo', require('./api/demo')

  console.log req

  return

index()

router.get '/', index
# router.get '/:id', controller.show
# router.post '/', controller.create
# router.put '/:id', controller.update
# router.patch '/:id', controller.update
# router.delete '/:id', controller.destroy

module.exports = router