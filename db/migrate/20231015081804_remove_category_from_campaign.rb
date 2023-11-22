class RemoveCategoryFromCampaign < ActiveRecord::Migration[7.0]
  def change
    remove_column :campaigns, :category
  end
end
