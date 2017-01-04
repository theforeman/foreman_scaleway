module FogExtensions
  module Scaleway
    module Server
      extend ActiveSupport::Concern

      included do
        alias_method :start, :poweron
        alias_method :stop, :poweroff
        alias_method :image_id, :image
        alias_method :image_id=, :image=
      end

      def image_name
        @image_name ||= image.try(:name)
      end

      def bootscript_title
        @bootscript_name ||= bootscript.try(:title)
      end

      def location_zone_id
        @location_zone_id ||= location.try(:[], 'zone_id')
      end

      def ipv6_address
        ipv6.try(:[], 'address')
      end

      def ip_addresses
        [public_ip_address, private_ip_address, ipv6_address].flatten.select(&:present?)
      end
    end
  end
end
