'use strict'

angular.module 'scomp'
.directive 'scpWidgetParameters', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/widget-parameters.directive.html'
  scope:
    _parameters: '=parameters'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, apiSpec) ->
    vm = @

    $scope.$watch 'vm._parameters', (_parameters) ->
      
      # console.log _parameters
      if _parameters.properties
        vm.schema = _parameters
      else if typeof _parameters.schema is 'object'
        schema = _parameters.schema


        if schema.$ref
          apiSpec.getDefinition schema.$ref
          .then (definition) ->
            vm.schema = definition.schema
            return
        else if schema.items and schema.items.$ref
          apiSpec.getDefinition schema.items.$ref
          .then (definition) ->
            vm.isArray = true
            vm.schema = definition.schema
            return

        return
      else
        vm.parameters = _parameters
      return



    # $scope.$watch 'vm._schema', (schema) ->
    #   if schema
    #     if schema.$ref
    #       apiSpec.getDefinition schema.$ref
    #       .then (definition) ->
    #         vm.schema = definition.schema
    #         return
    #     else if schema.items and schema.items.$ref
    #       apiSpec.getDefinition schema.items.$ref
    #       .then (definition) ->
    #         vm.isArray = true
    #         vm.schema = definition.schema
    #         return
    #   else
    #     vm.schema = schema
    #   return

    vm.getSchemaRef = (value) ->
      ref = ''
      if value.$ref
        ref = value.$ref
      else if value.items and value.items.$ref
        ref = value.items.$ref
      if ref
        return ref.split('/').pop()
      return


    return
