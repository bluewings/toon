'use strict'

express = require('express')
http = require('http')
# controller = require('./creative.controller')

router = express.Router()


url = require('url')

# test = 'http://map.naver.com/spirra/findCarRoute.nhn?route=route3&output=json&result=web3&coord_type=naver&search=2&car=0&mileage=12.4&start=126.9747750%2C37.2837500%2C%EC%88%98%EC%9B%90%EC%9D%BC%EC%9B%94%EC%B4%88%EB%93%B1%ED%95%99%EA%B5%90&destination=127.1058730%2C37.3593680%2CNAVER+(%EA%B7%B8%EB%A6%B0%ED%8C%A9%ED%86%A0%EB%A6%AC)&via='
# urlParts = url.parse(test, true)

# console.log urlParts

index = (req, res) ->
  console.log '>>>> query'
  console.log req.query.uri
  uri = 'http://map.naver.com/spirra/findCarRoute.nhn?route=route3&output=json&result=web3&coord_type=naver&search=2&car=0&mileage=12.4&start=126.9747750%2C37.2837500%2C%EC%88%98%EC%9B%90%EC%9D%BC%EC%9B%94%EC%B4%88%EB%93%B1%ED%95%99%EA%B5%90&destination=127.1058730%2C37.3593680%2CNAVER+(%EA%B7%B8%EB%A6%B0%ED%8C%A9%ED%86%A0%EB%A6%AC)&via='

  if req.query.uri
    urlParts = url.parse req.query.uri, true
  else
    urlParts = url.parse uri, true

  req = {}
  # app.use '/demo', require('./api/demo')
  
  # host = 'map.naver.com'
  # path = '/spirra/findCarRoute.nhn?route=route3&output=json&result=web3&coord_type=naver&search=2&car=0&mileage=12.4&start=126.9747750%2C37.2837500%2C%EC%88%98%EC%9B%90%EC%9D%BC%EC%9B%94%EC%B4%88%EB%93%B1%ED%95%99%EA%B5%90&destination=127.1058730%2C37.3593680%2CNAVER+(%EA%B7%B8%EB%A6%B0%ED%8C%A9%ED%86%A0%EB%A6%AC)&via='

  # # path = '/mappoi/picker?request=polygonToFeatures&version=1.4&sourcecrs=EPSG%3A4326&order=simple&output=json&coords=126.8633158%2C37.2499536%7C127.2123261%2C37.4160177&level=7'

  # console.log req.query.uri
  console.log urlParts

  req = http.get 
    host: urlParts.host
    path: urlParts.path
    # port: '80'
    # method: 'GET'
  , (response) ->
    response.setEncoding('utf8')
    body = ''
    response.on 'data', (d) ->
      body += d
      return
    response.on 'end', (d) ->
      res.send body
      # console.log body
      return


  return

# index()

router.get '/', index
# router.get '/:id', controller.show
# router.post '/', controller.create
# router.put '/:id', controller.update
# router.patch '/:id', controller.update
# router.delete '/:id', controller.destroy

module.exports = router