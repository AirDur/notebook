class CreateWildlifeship < ActiveRecord::Migration[4.2]
  def change
    create_table :wildlifeships do |t|
      t.integer :user_id
      t.integer :creature_id
      t.integer :habitat_id
    end
  end
end
