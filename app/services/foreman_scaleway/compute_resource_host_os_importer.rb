module ForemanScaleway
  module ComputeResourceHostOsImporter
    extend ActiveSupport::Concern

    module Overrides
      def initialize(*args)
        super
        initialize_os
      end
    end

    included do
      prepend Overrides
    end

    def initialize_os
      return unless vm.respond_to?(:image_id)
      return if vm.image_id.nil?
      image_id = case vm.image_id
      when ::Fog::Scaleway::Compute::Image
        vm.image_id.id
      else
        vm.image_id
      end
      image = Image.find_by(
        :compute_resource => compute_resource,
        :uuid => image_id
      )
      return if image.nil?
      logger.info "Found Operatingsystem #{image.operatingsystem} for Image ID #{image_id}."
      host.operatingsystem = image.operatingsystem
    end
  end
end
