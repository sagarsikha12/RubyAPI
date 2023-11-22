class ChangeToDefaultApprovedColumn < ActiveRecord::Migration[7.0]

  def change
    change_column_default :campaigns, :approved, from: nil, to: false
  end
end
