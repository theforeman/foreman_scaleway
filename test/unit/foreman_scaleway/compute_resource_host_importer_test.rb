require 'test_plugin_helper'

module ForemanScaleway
  class ComputeResourceHostImporterTest < ActiveSupport::TestCase
    setup { Fog.mock! }
    teardown { Fog.unmock! }

    let(:importer) do
      ComputeResourceHostImporter.new(
        :compute_resource => compute_resource,
        :vm => vm
      )
    end
    let(:host) { importer.host }


    context 'on scaleway' do
      let(:compute_resource) do
        cr = FactoryBot.create(:compute_resource, :scaleway)
        ComputeResource.find_by_id(cr.id)
      end
      let(:compute) { compute_resource.send(:client) }
      let(:image_id) { 'eeb73cbf-78a9-4481-9e38-9aaadaf8e0c9' }
      let(:architecture) { FactoryBot.create(:architecture, :name => 'armv7l') }
      let(:operatingsystem) { FactoryBot.create(:operatingsystem, :architectures => [architecture]) }

      let(:vm) do
        compute.servers.new(
          :name  => 'test.example.com',
          :image => image_id,
          :commercial_type => 'C1'
        )
      end
      setup do
        @domain = FactoryBot.create(:domain, :name => 'example.com')
        @image = FactoryBot.create(:image, :uuid => image_id, :compute_resource => compute_resource, :operatingsystem => operatingsystem)
        vm.save
      end

      test 'imports the VM with all parameters' do
        assert_equal 'test', host.name
        assert_equal vm.id, host.uuid
        assert_equal @domain, host.domain
        assert_equal architecture, host.architecture
        assert_equal operatingsystem, host.operatingsystem
      end
    end
  end
end
