class EntityValueIsNull < ActiveRecord::Migration
  def change
    change_column :entities, :value, :float, null: true
  end
end
