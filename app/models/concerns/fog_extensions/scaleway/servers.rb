module FogExtensions
  module Scaleway
    module Servers
      extend ActiveSupport::Concern

      included do
        alias_method_chain :all, :patched_arguments
      end

      # Scaleway servers.all doesn't take any argument, against the fog
      # standard, so we override the method.
      # TODO: Send pull request
      def all_with_patched_arguments(_options = {})
        all_without_patched_arguments
      end
    end
  end
end
