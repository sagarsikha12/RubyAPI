
class ChangeReviewedToApprovedInCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :approved, :boolean, default: false
  end

end
