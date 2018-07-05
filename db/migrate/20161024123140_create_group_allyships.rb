class CreateGroupAllyships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_allyships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :ally_id
    end
  end
end
