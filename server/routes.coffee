'use strict'

module.exports = (app) ->

  # Insert routes below
  # app.use '/api/creatives', require('./api/creative')
  # app.use '/api/slides', require('./api/slide')
  app.use '/auth', require('./auth')
  app.use '/tooltip', require('./api/tooltip')
  app.use '/translation', require('./api/translation')
  app.use '/feedback', require('./api/feedback')
  app.use '/demo', require('./api/demo')
  app.use '/markdown-content', require('./api/markdown-content')
  app.use '/proxy', require('./api/proxy')

  return
