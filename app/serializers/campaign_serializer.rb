class CampaignSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :title, :user_id, :created_at, :updated_at, :approved, :cover_image_url, :image_urls

  def cover_image_url
    if object.cover_image.attached?
      rails_blob_url(object.cover_image, only_path: true)
    elsif object.cover_image_url.present?
      object.cover_image_url
    else
      nil
    end
  end

  def image_urls
    object.images.attached? ? object.images.map { |image| rails_blob_url(image, only_path: true) } : []
  end
end
