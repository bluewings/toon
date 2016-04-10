'use strict'

angular.module 'scomp'
.filter 'duration', ->
  (duration) ->
    display = []
    totalMinutes = Math.floor(duration / 60)
    hours = Math.floor(totalMinutes / 60)
    minutes = totalMinutes % 60
    if hours
      display.push hours + '시간'
    display.push minutes + '분'
    display.join ' '

.filter 'roadSummary', ($filter) ->
  (roadSummary) ->
    results = []
    for road in roadSummary
      results.push road.road_name + ' (' + $filter('number')(road.distance / 1000, 2) + 'km)'
    results.join ' → '

.service 'nmapDataApi', ($http) ->

  getPaths = (steps, paths = []) ->
    for step in steps
      if step.path
        points = step.path.split /\s+/
        for point in points
          chunk = point.split ','
          if chunk.length is 2
            latlng = nhn.mapcore.CoordConverter.fromInnerToLatLng(new nhn.api.map.Inner(chunk[0], chunk[1]))
            paths.push [latlng.x, latlng.y, step.panorama]
            # console.log step.panorama

      else if step.steps
        getPaths step.steps, paths
    paths

  typeahead: (val) ->
    uri = ['http://ac.map.naver.com/ac']
    uri.push '?st=01'
    uri.push '&r_lt=01'
    uri.push '&r_format=json'
    uri.push '&t_koreng=1'
    uri.push '&q_enc=UTF-8'
    uri.push '&r_enc=UTF-8'
    uri.push '&r_unicode=0'
    uri.push '&r_escape=1'
    uri.push '&frm=pcweb'
    uri.push '&q=' + encodeURIComponent(val)

    $http.get '/proxy', 
      params:
        uri: uri.join ''
    .then (response) ->
      results = []
      for item in response.data.items
        for each in item
          results.push each
      results

  search: (name) ->
    uri = ['http://map.naver.com/search2/local.nhn']
    uri.push '?sm=hty'
    uri.push '&searchCoord=127.1053945%3B37.360644'
    uri.push '&isFirstSearch=true'
    uri.push '&menu=route'
    uri.push '&mpx=02135550%3A37.360644%2C127.1053945%3AZ12%3A0.0106543%2C0.0032185'
    uri.push '&query=' + encodeURIComponent(name)

    $http.get '/proxy', 
      params:
        uri: uri.join ''
    .then (response) ->
      response.data.result.site.list

  # findCarRoute: (from, to) ->
  #   uri = ['http://map.naver.com/spirra/findCarRoute.nhn']
  #   uri.push '?route=route3'
  #   uri.push '&output=json'
  #   uri.push '&result=web3'
  #   uri.push '&coord_type=naver'
  #   uri.push '&search=2'
  #   uri.push '&car=0'
  #   uri.push '&mileage=12.4'
  #   uri.push "&start=#{from.x},#{from.y}," + encodeURIComponent(from.name.replace(/\s+/g, '+'))
  #   uri.push "&destination=#{to.x},#{to.y}," + encodeURIComponent(to.name.replace(/\s+/g, '+'))
  #   uri.push '&via='

  #   $http.get '/proxy', 
  #     params:
  #       uri: uri.join ''
  #   .then (response) ->
  #     routes = response.data.routes
  #     for route in routes
  #       route.paths = getPaths route.legs[0].steps
  #     routes
  findCarRoute: (from, to) ->
    uri = ['http://map.naver.com/spirra/findCarRoute.nhn']
    uri.push '?route=route3'
    uri.push '&output=json'
    uri.push '&result=web3'
    uri.push '&coord_type=naver'
    uri.push '&search=2'
    uri.push '&car=0'
    uri.push '&mileage=12.4'
    uri.push "&start=#{from.x},#{from.y}," + encodeURIComponent(from.name.replace(/\s+/g, '+'))
    uri.push "&destination=#{to.x},#{to.y}," + encodeURIComponent(to.name.replace(/\s+/g, '+'))
    uri.push '&via='

    $http.get '/proxy', 
      params:
        uri: uri.join ''
    .then (response) ->
      routes = response.data.routes

      

      for route in routes
        # route.paths = getPaths route.legs[0].steps
        prev = null
        accumDist = 0
        route.paths = []
        min = null
        max = null


        for point in getPaths route.legs[0].steps

          if point[0] > 0 and point[1] > 0
            

            if prev
              x1 = prev[0]
              y1 = prev[1]
              x2 = point[0]
              y2 = point[1]
              dist = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))

              if dist > 0

                # route.paths.push [x1, y1, x2, y2, dist]
                degree = Math.atan2(y2 - y1, x2 - x1) * 180 / Math.PI - 90 + 90


                route.paths.push 
                  sx: x1
                  sy: y1
                  ex: x2
                  ey: y2
                  dist: dist
                  start: accumDist
                  end: accumDist + dist
                  degree: degree
                  panorama: point[2]

                accumDist += dist
                  
              # else
              #   console.log [x1, y1, x2, y2, dist]

            if min is null
              min = x: point[0], y: point[1]
              max = x: point[0], y: point[1]

            if min.x > point[0]
              min.x = point[0]
            if min.y > point[1]
              min.y = point[1]
            if max.x < point[0]
              max.x = point[0]
            if max.y < point[1]
              max.y = point[1]



            prev = point

        # for path in route.paths
        #   path.push parseInt(path[4] / accumDist * 10000, 10) / 100
        route.total = accumDist
        route.min = min
        route.max = max
        route.width = route.max.x - route.min.x
        route.height = route.max.y - route.min.y
        console.log route.dist
      routes



.controller 'ApiMainController', ($scope, markdown, $timeout, $element, $http, $q, nmapDataApi) ->
  vm = @


  # vm.message = ->
  #   name = prompt '당신의 이름은 무엇입니까?'

  #   alert name + '님 싸우자.'




















  vm.findCarRoute = ->
    if vm.input.from.selected and vm.input.to.selected
      nmapDataApi.findCarRoute vm.input.from.selected, vm.input.to.selected
      .then (routes) ->
        vm.routes = routes
        vm.selectRoute routes[0]
        console.log routes
        return
    return

  vm.selectRoute = (route) ->
    vm.route = route
    console.log route
    return

  vm.input = 
    from:
      text: ''
      selected: null
    to:
      text: ''
      selected: null
    query: nmapDataApi.typeahead
    edit: (type, edit = true) ->
      self = @
      self[type]._edit = edit
      if self[type].selected and self[type]._edit
        self[type].text = self[type].selected.name
      else
        self[type].text = ''
      return
    onselect: (type, item) ->
      self = @
      nmapDataApi.search item
      .then (results) ->
        self[type].selected = results[0]
        vm.input[type].text = ''
        delete vm.input[type]._edit
        if type is 'from' and !vm.input.to.selected
          vm.input.edit('to')
        return
      return

  getLatLng = (innerStr) ->
    chunk = innerStr.split ','
    latlng = nhn.mapcore.CoordConverter.fromInnerToLatLng(new nhn.api.map.Inner(chunk[0], chunk[1]))
    x: latlng.x, y: latlng.y

  # $scope.$watch 'vm.route', (route) ->
  #   if route and route.summary

  #     tl = getLatLng route.summary.bounds.left_top
  #     br = getLatLng route.summary.bounds.right_bottom
  #     # center = [(tl.x + br.x) / 2, (tl.y + br.y) / 2]

  #     vm.nmapOptions =
  #       center:
  #         x: (tl.x + br.x) / 2, y: (tl.y + br.y) / 2
  #       route:
  #         from: getLatLng route.summary.start.location
  #         to: getLatLng route.summary.end.location
  #       paths: route.paths


  #     console.log route.summary
  #   return



  findPoint = (route, percent) ->
    curr = route.total * percent
    accum = 0
    lenFr = 0
    lenTo = 0
    lastX = null
    lastY = null

    # last = null
    prev = null
    for path in route.paths
      if path.start < curr and curr <= path.end
        # last = path
        percent = (curr - path.start) / path.dist
        break
      # prev = path

    point =
      x: path.sx + (path.ex - path.sx) * percent
      y: path.sy + (path.ey - path.sy) * percent
      degree: path.degree
      panorama: path.panorama
        # path: path
    #   lenTo = lenFr +
    point

    # currPosition = pathGroup.length * percent
    # lengthFr = 0
    # lengthTo = 0
    # lastX = 0
    # lastY = 0
    # for path, i in pathGroup.paths
    #   if path.length
    #     lengthTo = lengthFr + path.length
    #   if lengthFr < currPosition and currPosition < lengthTo
    #     percent = (currPosition - lengthFr) / (lengthTo - lengthFr)
    #     break
    #   lengthFr = lengthTo
    #   lastX = path._x
    #   lastY = path._y

    # if path.cmd.toUpperCase() is 'C'
    #   bezierPoint = bezier(percent,
    #     { x: lastX, y: lastY },
    #     { x: path._x1, y: path._y1 },
    #     { x: path._x2, y: path._y2 },
    #     { x: path._x, y: path._y }
    #   )
    #   point =
    #     x: bezierPoint.x
    #     y: bezierPoint.y
    #     path: path
    # else
    #   point =
    #     x: lastX + (path._x - lastX) * percent
    #     y: lastY + (path._y - lastY) * percent
    #     path: path
    # point

  width = 400
  height = 400

  nmapContainer = $element.find('.nmap-container').css({
    width: width
    height: height
  })[0]


  gmapContainer = $element.find('.gmap-container').css({
    width: width
    height: height
  })[0]


  carContainer = $element.find('.car-container').css({
    width: width
    height: height
  })

  car = $element.find('.car img')


  centerPoint = new nhn.api.map.LatLng()

  if nmapContainer

    nmap = new nhn.api.map.Map(nmapContainer, {
      zoom: 11
      mapMode: 0
    })

  if gmapContainer

    gmap = new google.maps.Map(gmapContainer, {
      center: {lat: 0, lng: 0},
      zoom: 18
    })
    gmap.setTilt 45
      
  prevPanoId = null

  $scope.$watch 'vm.route', (route) ->
    if route and route.paths
      # canvas = $element.find('canvas')[0]
      # ctx = canvas.getContext '2d'
      # canvas.width = 1000
      # console.log route.width, route.height
      # canvas.height = parseInt(canvas.width / route.width * route.height, 10)


      anim = $({
        process: 0
      }).animate({
        process: 1
      }, {
        duration: 100000
        easing: 'linear'
        step: (now, fx) ->

          point = findPoint route, now

          centerPoint.x = point.x
          centerPoint.y = point.y

          $(gmapContainer).css
            transform: "rotate(#{point.degree}deg)"


          $(carContainer).css
            transform: "rotate(#{point.degree}deg)"
          $(car).css
            transform: "rotate(#{-point.degree}deg)"

          # $('#test1').html centerPoint.x + ' , ' + centerPoint.y

          # # console.log centerPoint
          # # http://map.naver.com/panorama/getPanorama.nhn?type=3&lat=37.2764946&lng=126.9702729&zoomlevel=11

          # if prevPanoId isnt point.panorama.id
          #   $('#testimg')[0].src = "http://pvimgl.map.naver.com/api/get?type=img&pano_id=#{point.panorama.id}&suffix=_P"
          #   $('#test').html JSON.stringify(point.panorama, null, 2)

          #   prevPanoId = point.panorama.id

          # http://pvimgl.map.naver.com/api/get?type=img&pano_id=GQ1NvOS0gPHxjb7NBn79RA==&suffix=_P
          # http://pvimgmb.map.naver.com/api/get?type=img&pano_id=GQ1NvOS0gPHxjb7NBn79RA==&suffix=_M_d_01_02 01_01 ~ 02_02


          if nmap

            nmap.setCenter centerPoint, { useEffect: false, centerMark: true }
          if gmap
            # gmap.setCenter point.x, po
            gmap.setCenter(new google.maps.LatLng(point.y, point.x))

          # rt = canvas.width / route.width
          # ctx.fillStyle = 'black'
          # ctx.fillRect (point.x - route.min.x) * rt, (point.y - route.min.y) * rt, 5, 5
          # console.log point.x * rt, point.y * rt

          # console.log now, point
      })

      # tl = getLatLng route.summary.bounds.left_top
      # br = getLatLng route.summary.bounds.right_bottom
      # # center = [(tl.x + br.x) / 2, (tl.y + br.y) / 2]

      # vm.nmapOptions =
      #   center:
      #     x: (tl.x + br.x) / 2, y: (tl.y + br.y) / 2
      #   route:
      #     from: getLatLng route.summary.start.location
      #     to: getLatLng route.summary.end.location
      #   paths: route.paths


      # console.log route.summary
    return

  $scope.$watch 'vm.input.from._edit', (edit) ->
    if edit
      $timeout ->
        $element.find('.form-from input').select()
        return
    return

  $scope.$watch 'vm.input.to._edit', (edit) ->
    if edit
      $timeout ->
        $element.find('.form-to input').select()
        return
    return

  vm.input.onselect 'from', '일월초등학교'
  vm.input.onselect 'to', '그린팩토리'

  $timeout ->
    vm.findCarRoute()
  , 1000

  return