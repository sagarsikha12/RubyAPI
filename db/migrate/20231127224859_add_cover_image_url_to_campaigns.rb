class AddCoverImageUrlToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :cover_image_url, :string
  end
end
