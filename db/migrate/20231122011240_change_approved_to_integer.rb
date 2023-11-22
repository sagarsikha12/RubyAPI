class ChangeApprovedToInteger < ActiveRecord::Migration[7.0]


  def change
    execute "ALTER TABLE campaigns ALTER approved DROP DEFAULT;"
    change_column :campaigns, :approved, :integer, using: "CASE approved WHEN true THEN 1 ELSE 0 END"
    change_column_default :campaigns, :approved, 0
  end
end
