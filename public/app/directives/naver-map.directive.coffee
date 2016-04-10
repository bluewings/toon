'use strict'

angular.module 'scomp'
.directive 'naverMap', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/naver-map.directive.html'
  scope:
    _schema: '=schema'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $element, $http, apiSpec) ->
    vm = @



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