class AddReviewedToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :reviewed, :boolean, default: false
  end
end
