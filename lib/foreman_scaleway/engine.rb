module ForemanScaleway
  class Engine < ::Rails::Engine
    engine_name 'foreman_scaleway'

    # config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    # config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    # config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    initializer 'foreman_scaleway.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_scaleway do
        requires_foreman '>= 1.13'

        compute_resource Scaleway
        parameter_filter ComputeResource, :api_token
      end
    end

    # Precompile any JS or CSS files under app/assets/
    # If requiring files from each other, list them explicitly here to avoid precompiling the same
    # content twice.
    assets_to_precompile =
      Dir.chdir(root) do
        Dir['app/assets/javascripts/**/*', 'app/assets/stylesheets/**/*'].map do |f|
          f.split(File::SEPARATOR, 4).last
        end
      end
    initializer 'foreman_scaleway.assets.precompile' do |app|
      app.config.assets.precompile += assets_to_precompile
    end
    initializer 'foreman_scaleway.configure_assets', group: :assets do
      SETTINGS[:foreman_scaleway] = { assets: { precompile: assets_to_precompile } }
    end

    config.to_prepare do
      begin
        require 'fog/scaleway'
        require 'fog/scaleway/models/compute/server'
        require 'fog/scaleway/models/compute/servers'
        require File.expand_path(
          '../../../app/models/concerns/fog_extensions/scaleway/servers', __FILE__
        )
        Fog::Scaleway::Compute::Servers.send(:include, FogExtensions::Scaleway::Servers)
        require File.expand_path(
          '../../../app/models/concerns/fog_extensions/scaleway/server', __FILE__
        )
        Fog::Scaleway::Compute::Server.send(:include, FogExtensions::Scaleway::Server)
      rescue => e
        Rails.logger.warn "ForemanScaleway: skipping engine hook (#{e})"
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanScaleway::Engine.load_seed
      end
    end

    initializer 'foreman_scaleway.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_scaleway'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
