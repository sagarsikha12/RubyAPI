# app/models/campaign.rb

class Campaign < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_rich_text :content
  has_one_attached :cover_image
  has_many_attached :images
  has_one :notification, dependent: :destroy # This already deletes notifications when a campaign is destroyed

  validates_associated :cover_image
  validates :title, presence: true, length: { maximum: 255 }

  # Other validations and associations...

  before_destroy :delete_associated_notifications
  enum approved: { pending: 0, accepted: 1, rejected: 2 }

  private

  def delete_associated_notifications
    self.notification.destroy if self.notification
  end
end
