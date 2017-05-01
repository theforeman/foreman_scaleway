module ScalewayHelper
  def scaleway_image_select(f, images, opts = {})
    new_vm = opts.fetch(:new_vm, true)
    select_f f,
             :image_id,
             images,
             :uuid,
             :name,
             {
               :include_blank => images.empty? || images.size == 1 ? false : _('Please select an image')
             },
             :disabled => !new_vm || images.empty?, :label => _('Image'), :label_size => 'col-md-2'
  end
end
