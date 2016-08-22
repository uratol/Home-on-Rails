class AddDataToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :data, :text
  end
end
