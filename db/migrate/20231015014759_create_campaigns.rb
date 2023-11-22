class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :cover_image
      t.string :category
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
