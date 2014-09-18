module Extensions
  module Image
    extend ActiveSupport::Concern
    included do

      mount_uploader :image, ImageUploader
      attr_accessor :remove_image
      attr_accessor :remote_image_url

    end
  end
end
