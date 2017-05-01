module FogExtensions
  module Scaleway
    module Servers
      # Scaleway servers.all doesn't take any argument, against the fog
      # standard, so we override the method.
      def all(_options = {})
        super()
      end
    end
  end
end
