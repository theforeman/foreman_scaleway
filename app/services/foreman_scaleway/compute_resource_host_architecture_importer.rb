module ForemanScaleway
  module ComputeResourceHostArchitectureImporter
    extend ActiveSupport::Concern

    module Overrides
      def initialize(*args)
        super
        initialize_architecture
      end
    end

    included do
      prepend Overrides
    end

    def initialize_architecture
      return unless vm.respond_to?(:foreman_architecture)
      return if vm.foreman_architecture.nil?
      host.architecture = Architecture.find_by(:name => vm.foreman_architecture)
    end
  end
end
