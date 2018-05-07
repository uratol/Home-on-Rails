class AddHiddenToEntities < ActiveRecord::Migration

  def up
    add_column :entities, :hidden, :boolean
    execute("update entities set hidden='t' where disabled = 't'")
    execute("update entities set hidden='f' where hidden is null")
    change_column :entities, :hidden, :boolean, null: false, default: false
  end

  def down
    remove_column :entities, :hidden
  end

end
