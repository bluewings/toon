'use strict'

angular.module 'scomp'
.directive 'scpIntro', ->
  restrict: 'E'
  templateUrl: 'app/directives/intro.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope) ->
    vm = @
    return
    # # , $rootScope, $state, $translate, $timeout, $element, $window, User, languages, statusReasons, global, globalNavigations) ->
    # vm = @


    # win = $($window)

    # vm.app = global.app

    # vm.local = global.local

    # vm.menus = globalNavigations

    # vm.languages = languages

    # vm.langKey = $translate.use()

    # resizeHandler = ->
    #   headerFixed = $element.find('.navbar-fixed-top')
    #   if vm.app.headerHeight isnt headerFixed.outerHeight()
    #     vm.app.headerHeight = headerFixed.outerHeight()
    #   return

    # updateState = ->
    #   vm.state = $state.current
    #   return

    # vm.logout = Auth.logout

    # vm.toggleRight = ->
    #   vm.local.showHelpGuide = if vm.local.showHelpGuide then false else true
    #   return

    # vm.toggleNanumGothic = ->
    #   vm.local.useNanumGothic = if vm.local.useNanumGothic then false else true
    #   return

    # vm.changeLanguage = (langKey) ->
    #   vm.langKey = langKey
    #   $translate.use langKey
    #   return

    # vm.closeAlert = ->
    #   delete vm.alertMessage
    #   vm.checkHeight()
    #   return

    # vm.checkHeight = ->
    #   $timeout resizeHandler
    #   return

    # User.get (user) ->
    #   vm.me = angular.extend {}, user
    #   return

    # resizeHandler()

    # updateState()

    # unbinds = []

    # unbinds.push win.$on 'resize', resizeHandler

    # unbinds.push $rootScope.$on '$stateChangeSuccess', updateState

    # $scope.$on 'clientCustomerChange', (event, customer) ->
    #   vm.customer = customer
    #   delete vm.alertMessage
    #   if vm.customer.bidStatus is 'PAUSED'
    #     statusReason = vm.customer.statusReason or vm.customer.pausedReason
    #     if statusReason and statusReasons[statusReason] and statusReasons[statusReason].desc
    #       vm.alertMessage = statusReasons[statusReason].desc.translationId
    #     else if statusReason and statusReasons[statusReason]
    #       vm.alertMessage = statusReasons[statusReason].translationId
    #     else if statusReason
    #       vm.alertMessage = statusReason
    #     else
    #       vm.alertMessage = vm.customer.bidStatus
    #   vm.checkHeight()
    #   return

    # $scope.$on '$destroy', ->
    #   for unbind in unbinds
    #     unbind()
    #   return

    # return