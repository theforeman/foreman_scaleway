module ForemanScaleway
  module ComputeResourcesVmsHelperExtensions
    extend ActiveSupport::Concern

    def scaleway_available_actions(vm, authorizer = nil)
      actions = []
      actions << vm_power_action(vm, authorizer)
      actions << vm_import_action(vm) if respond_to?(:vm_import_action)
      actions.compact!
      return actions.first if actions.size == 1
      action_buttons(actions)
    end
  end
end
