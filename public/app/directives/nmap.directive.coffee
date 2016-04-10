'use strict'



findPoint = (pathGroup, percent) ->
  currPosition = pathGroup.length * percent
  lengthFr = 0
  lengthTo = 0
  lastX = 0
  lastY = 0
  for path, i in pathGroup.paths
    if path.length
      lengthTo = lengthFr + path.length
    if lengthFr < currPosition and currPosition < lengthTo
      percent = (currPosition - lengthFr) / (lengthTo - lengthFr)
      break
    lengthFr = lengthTo
    lastX = path._x
    lastY = path._y

  if path.cmd.toUpperCase() is 'C'
    bezierPoint = bezier(percent,
      { x: lastX, y: lastY },
      { x: path._x1, y: path._y1 },
      { x: path._x2, y: path._y2 },
      { x: path._x, y: path._y }
    )
    point =
      x: bezierPoint.x
      y: bezierPoint.y
      path: path
  else
    point =
      x: lastX + (path._x - lastX) * percent
      y: lastY + (path._y - lastY) * percent
      path: path
  point

angular.module 'scomp'
.directive 'nmap', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/nmap.directive.html'
  scope:
    _nmapOptions: '=nmapOptions'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $element, $http, apiSpec) ->
    vm = @

    width = 2000
    height = 2000

    canvas = $element.find('canvas')[0]
    ctx = canvas.getContext('2d')

    nmapContainer = $element.find('.nmap-container').css({
      width: width
      height: height
    })[0]

    canvas.width = width
    canvas.height = height
    ctx.strokeRect width / 2 - 10, height / 2 - 10, 20, 20

    centerPoint = new nhn.api.map.LatLng()

    nmap = new nhn.api.map.Map(nmapContainer, {
      zoom: 11
      mapMode: 0
    })

    prev = null

    $nmap = $(nmapContainer).find('.nmap')
    # $nmap.css 'transition', '1s transform'

    animateFn = ->

      if vm._nmapOptions and vm._nmapOptions.paths and vm._nmapOptions.paths.length > 0
        path = vm._nmapOptions.paths.shift()

        # vm._nmapOptions.paths.push path

        centerPoint = new nhn.api.map.LatLng()
        
        centerPoint.x = path[0]
        centerPoint.y = path[1]

        # $(nmapContainer).find('.nmap').css('overflow', 'visible')





        if prev and prev.x is centerPoint.x and prev.y is centerPoint.y
          # console.log prev.x, centerPoint.x, prev.y, centerPoint.y
          console.log 'skip'
        else 
          if prev
            # console.log centerPoint.x - prev.x, centerPoint.y - prev.y

            vm.angleDeg = Math.atan2(centerPoint.y - prev.y, centerPoint.x - prev.x) * 180 / Math.PI - 90

            $nmap.css
              transform: "rotate(#{vm.angleDeg}deg)"
            # console.log vm.angleDeg
          # nmap.setCenter centerPoint, useEffect: true

          if prev
            a = Math.pow(centerPoint.x - prev.x, 2)
            b = Math.pow(centerPoint.y - prev.y, 2)
            console.log centerPoint.x, centerPoint.y, Math.sqrt(a + b) * 1000000


          if Math.sqrt(a + b) * 1000000 > 100
            nmap.setCenter centerPoint, { useEffect: false, centerMark: true }
          # nmap.setCenterBy 1, 1



        prev =
          x: centerPoint.x
          y: centerPoint.y




        # setTimeout ->
        #   $(nmapContainer).find('img').not('.done').addClass('done newbie').each (index, item) ->
        #     do (item) ->
        #       setTimeout ->
        #         $(item).removeClass('newbie')
        #       , 1000
        #     return
        # , 100
        # curr = nhn.mapcore.CoordConverter.fromLatLngToInner(centerPoint)
        # level = nmap.getLevel()


        # unless prev

        #   nmap.setCenter centerPoint 

        # else
        #   console.log curr, curr.x - prev.x, curr.y - prev.y, level

          
        #   nmap.setCenterBy curr.x - prev.x, curr.y - prev.y          

        # prev = curr

        # nmap.setCenterBy
    

      setTimeout ->
        requestAnimationFrame animateFn
      , 1000
    animateFn()

    $scope.$on '$destroy', ->
      clearInterval interval
      return

    $scope.$watch 'vm._nmapOptions.center', (center) ->
      if center
        # point = nhn.api.map.LatLng(center.x, center.y)
        # console.log point
        centerPoint.x = center.x
        centerPoint.y = center.y

        nmap.setCenter centerPoint
      return




    # oMap = new nhn.api.map.Map(nmapContainer, {
    #   point : oSeoulCityPoint
    #   zoom: 8
    #   minMaxLevel : [ 1, 14 ]
    #   size : new nhn.api.map.Size(size[0], size[1])          
    # })


    return

    mapWrapper = $element.find('.map-wrapper').css({
      width: 400
      height: 300
      # backgroundColor: 'yellow'
    })[0]

    bbox = [126.863316, 37.249954, 127.212326, 37.416018]

    size = [800, 700]

    canvas = $element.find('canvas')[0]
    ctx = canvas.getContext '2d'

    width = size[0]
    height = size[1]
    canvas.width = size[0]
    canvas.height = size[1]


    oSeoulCityPoint = new nhn.api.map.LatLng((bbox[1] + bbox[3]) / 2, (bbox[0] + bbox[2]) / 2)

    oMap = new nhn.api.map.Map(mapWrapper, {
      point : oSeoulCityPoint
      zoom: 8
      minMaxLevel : [ 1, 14 ]
      size : new nhn.api.map.Size(size[0], size[1])          
    })

    bound = oMap.getBound()

    convPoint = (lat, lng) ->
      width = canvas.width
      height = canvas.height
      
      tl =
        x: bound[0].x
        y: bound[0].y
      br =
        x: bound[1].x
        y: bound[1].y

      latlng = new nhn.api.map.LatLng(lng, lat)

      # console.log latlng.toLatLng()
      # console.log latlng.toUTMK()
      # console.log latlng.toTM128()
      console.log latlng.getX(), latlng.getY()
      



      x: (lat - tl.x) / (br.x - tl.x) * width
      y: height - (lng - br.y) / (br.y - tl.y) * height * -1


      # console.log  (lat - tl.x)
      # console.log  (br.x - tl.x)


      # return


    $http.get '/proxy'
    .then (response) ->

      # console.log response.data
      routes = response.data.routes

      steps = routes[2].legs[0].steps

      console.log steps
      ctx.beginPath()
      ctx.lineWidth = 5
      ctx.strokeStyle = 'blue'
      for step, i in steps

        if step.steps and step.steps.length > 0

          for subStep in step.steps

            if subStep.path


              paths = subStep.path.split ' '
              # console.log paths

              
              for path, j in paths
                chunk = path.split ','

                test = nhn.mapcore.CoordConverter.fromLatLngToInner(oSeoulCityPoint)

                test.x = parseInt chunk[0], 10
                test.y = parseInt chunk[1], 10
          

                latlng = nhn.mapcore.CoordConverter.fromInnerToLatLng(test)


                pt = convPoint latlng.x, latlng.y

                ctx.lineTo pt.x, pt.y



        else if step.path 
          # console.log step
          paths = step.path.split ' '
          # console.log paths

          
          for path, j in paths
            chunk = path.split ','

            test = nhn.mapcore.CoordConverter.fromLatLngToInner(oSeoulCityPoint)

            test.x = parseInt chunk[0], 10
            test.y = parseInt chunk[1], 10
      

            latlng = nhn.mapcore.CoordConverter.fromInnerToLatLng(test)


            pt = convPoint latlng.x, latlng.y

            ctx.lineTo pt.x, pt.y

            if j is 0

              ctx.fillText i, pt.x, pt.y

          
          # console.log latlng
      ctx.stroke()
      test = nhn.mapcore.CoordConverter.fromLatLngToInner(oSeoulCityPoint)
      # console.log scale
      # console.log test
      

      return




      bbox = response.data.bbox
      features = response.data.features

      i = 0
      for feature in features
        if feature and feature.geometry and feature.geometry.type is 'Point'
          # console.log feature.geometry
          # pt = convPoint feature.geometry.coordinates[0], feature.geometry.coordinates[1]

          pt1 = convPoint feature.bbox[0], feature.bbox[1]
          pt2 = convPoint feature.bbox[2], feature.bbox[3]
          # if isFirst
             
          #   ctx.moveTo pt.x, pt.y

          i++

          # else
          ctx.fillStyle = 'yellow'
          ctx.fillRect pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y
          ctx.fillStyle = 'black'
          ctx.fillText i, pt1.x, pt2.y
          # console.log pt
          isFirst = false

      isFirst = true


      ctx.beginPath()
      for feature in features
        if feature and feature.geometry and feature.geometry.type is 'Point'
          # console.log feature.geometry
          pt = convPoint feature.geometry.coordinates[0], feature.geometry.coordinates[1]

          pt1 = convPoint feature.bbox[0], feature.bbox[1]
          pt2 = convPoint feature.bbox[2], feature.bbox[3]
          # if isFirst
             
          #   ctx.moveTo pt.x, pt.y

          # else
          ctx.lineTo pt.x, pt.y
          # console.log pt
          isFirst = false

      ctx.stroke()

      # coor = function (h, i) {
      #   if (h > i) {
      #     return (h - i) * f
      #   } else {
      #     return 0
      #   }
      # };

      scale = nhn.mapcore.mapSpec.getScale(oMap.getLevel())

      test = nhn.mapcore.CoordConverter.fromLatLngToInner(oSeoulCityPoint)
      console.log scale
      console.log test
      # nhn.mapcore.CoordConverter.fromInnerToLatLng


      # console.log convPoint bbox[0], bbox[1]
      # console.log convPoint bbox[2], bbox[3]



      # console.log oMap.getBound()

    return


# bbox: [126.863316, 37.249954, 127.212326, 37.416018]
# 0: 126.863316
# 1: 37.249954
# 2: 127.212326
# 3: 37.416018