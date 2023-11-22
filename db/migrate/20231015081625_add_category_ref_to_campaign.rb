class AddCategoryRefToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_reference :campaigns, :category, null: false, foreign_key: true
  end
end
