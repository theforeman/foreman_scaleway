module ScalewayHelper
  def scaleway_image_select(f, images)
    select_f f,
             :image_id,
             images,
             :uuid,
             :name,
             {
               :include_blank => images.empty? || images.size == 1 ? false : _('Please select an image')
             },
             :disabled => images.empty?, :label => _('Image'), :label_size => 'col-md-2'
  end
end
