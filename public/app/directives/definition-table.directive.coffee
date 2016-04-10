'use strict'

angular.module 'scomp'
.directive 'apiDefinitionTable', ($compile) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/definition-table.directive.html'
  scope:
    _schema: '=schema'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, apiSpec) ->
    vm = @

    # vm.isArray = false


    $scope.$watch 'vm._schema', (schema) ->
      if schema
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
      else
        vm.schema = schema
      return

    vm.getSchemaRef = (value) ->
      ref = ''
      if value.$ref
        ref = value.$ref
      else if value.items and value.items.$ref
        ref = value.items.$ref
      if ref
        return ref.split('/').pop()
      return

    # apiSpec.getTags().then (tags) ->
    #   vm.tags = tags

    #   apiSpec.getDefinitions().then (definitions) ->
    #     vm.definitions = definitions
    #     return

    #   return



    return
