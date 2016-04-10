'use strict'

angular.module 'scomp'
.directive 'scpSwitchCheckbox', ($compile, templateUtil) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    # prevent infinite loop when recompiled
    element.removeAttr 'scp-switch-checkbox'

    templateUtil.get('switch-checkbox').then (template) ->
      wrapper = $compile(template({
        hasLabel: if element.closest('label').size() > 0 then true else false
        size: (attrs and attrs.size) or 'sm'
      }))(scope)
      element.replaceWith wrapper
      wrapper.find('[transclude]').eq(0).replaceWith element 
      $compile(element)(scope)
      return
    
    return