module ForemanScaleway
  class Scaleway < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy

    alias_attribute :api_organization, :user
    alias_attribute :api_token, :password
    alias_attribute :region, :url

    validates :api_token, :api_organization, :presence => true

    before_validation :set_organization

    after_create :setup_key_pair
    after_destroy :destroy_key_pair

    def self.model_name
      ComputeResource.model_name
    end

    def self.available?
      Fog::Compute.providers.include?(:scaleway)
    end

    def capabilities
      [:image]
    end

    def new_vm(attr = {})
      test_connection
      return unless errors.empty?

      opts = vm_instance_defaults.merge(attr.to_hash).deep_symbolize_keys

      opts = parse_args(opts)

      vm = client.servers.new(opts)
      vm
    end

    def create_vm(args = {})
      vm = new_vm(args)
      Rails.logger.debug "creating VM with the following options: #{vm.inspect}"

      vm.save
      vm.poweron(false)

      vm
    rescue Fog::Errors::Error => e
      Foreman::Logging.exception('Unhandled Scaleway error', e)
      raise e
    end

    def save_vm(uuid, attr)
      attr = parse_args(attr)
      super(uuid, attr)
    end

    def update_required?(old_attrs, new_attrs)
      super(old_attrs.deep_merge(old_attrs) { |_, _, v| v.to_s }, new_attrs)
    end

    def provided_attributes
      super.merge(:ip => :public_ip_address, :ip6 => :ipv6_address)
    end

    def available_images
      client.images.all
    end

    def self.provider_friendly_name
      'Scaleway'
    end

    def associated_host(vm)
      associate_by('ip', [vm.public_ip_address, vm.private_ip_address])
    end

    def supports_update?
      true
    end

    def test_connection(options = {})
      super
      errors[:api_token].empty? && available_images
    rescue Excon::Errors::Unauthorized => e
      errors[:base] << e.response.body
    rescue Fog::Errors::Error => e
      errors[:base] << e.message
    end

    def set_organization
      return true unless api_token.present?
      organization_id = account.try(:organizations).try(:first).try(:id)
      raise Foreman::Exception, N_('Could not retrieve Scaleway organization_id.') unless organization_id.present?
      self.api_organization = organization_id
      true
    end

    # Hard coded default data
    def regions
      %w(par1 ams1)
    end

    def flavors
      %w(C1 VC1S VC1M VC1L C2S C2M C2L X64-2GB X64-4GB X64-8GB X64-15GB X64-30GB X64-60GB X64-120GB ARM64-2GB ARM64-4GB ARM64-8GB)
    end

    private

    # Overwritten because fog-scaleway's volumes is a hash and not an array as expected in core
    def set_vm_volumes_attributes(vm, vm_attrs)
      volumes = vm.volumes || {}
      vm_attrs[:volumes_attributes] = Hash[volumes.map { |idx, volume| [idx.to_s, volume.attributes] }]
      vm_attrs
    end

    def parse_args(attr)
      opts = attr.dup.with_indifferent_access
      opts[:enable_ipv6] = Foreman::Cast.to_bool(opts[:enable_ipv6])
      opts[:dynamic_ip_required] = Foreman::Cast.to_bool(opts[:dynamic_ip_required])
      opts.delete(:image_id)
      opts
    end

    def client
      @client ||= Fog::Compute.new(
        :provider => :scaleway,
        :scaleway_token => api_token,
        :scaleway_organization => api_organization,
        :scaleway_region => region
      )
    end

    def account
      @account ||= Fog::Account.new(
        :provider => :scaleway,
        :scaleway_token => api_token
      )
    end

    def vm_instance_defaults
      super.merge(
        :enable_ipv6 => true,
        :dynamic_ip_required => true
      )
    end

    # this method creates a new key pair for each new Scaleway compute resource
    # it should create the key and upload it to Scaleway
    def setup_key_pair
      public_key, private_key = generate_key
      key_name = "foreman-#{id}#{Foreman.uuid}"
      Rails.logger.debug "Generated new SSH-Key: #{key_name} -> #{public_key}"
      set_ssh_key(key_name, public_key)
      KeyPair.create! :name => key_name, :compute_resource_id => id, :secret => private_key
    rescue => e
      Foreman::Logging.exception('Failed to generate key pair', e)
      destroy_key_pair
      raise
    end

    def destroy_key_pair
      return unless key_pair
      logger.info "removing Scaleway key #{key_pair.name}"
      remove_ssh_key(key_pair.name)
      key_pair.destroy
      true
    rescue => e
      logger.warn "failed to delete key pair from Scaleway, you might need to cleanup manually : #{e}"
    end

    def set_ssh_key(key_name, public_key)
      with_user do |user|
        Rails.logger.debug "Existing keys: #{user.ssh_public_keys.inspect}"
        user.ssh_public_keys << { 'key' => [public_key, key_name].join(' ') }
        Rails.logger.debug "Key, that will be written: #{user.ssh_public_keys.inspect}"
      end
    end

    def remove_ssh_key(key_name)
      with_user do |user|
        user.ssh_public_keys.select! { |k| !k['key'].end_with?(key_name) }
      end
    end

    def with_user
      user = account.users.first
      yield(user)
      user.save
    end

    def generate_key
      key = OpenSSL::PKey::RSA.new 2048
      type = key.ssh_type
      data = [key.to_blob].pack('m0')

      openssh_format_public_key = "#{type} #{data}"
      [openssh_format_public_key, key.to_pem]
    end
  end
end
