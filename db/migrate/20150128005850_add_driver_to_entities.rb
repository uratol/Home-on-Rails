class AddDriverToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :driver, :string 
  end
end
