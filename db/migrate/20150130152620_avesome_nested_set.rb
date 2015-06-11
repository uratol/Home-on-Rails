class AvesomeNestedSet < ActiveRecord::Migration
  def up
    add_column :entities, :lft,  :integer, index: true
    add_column :entities, :rgt,  :integer, index: true
    add_column :entities, :depth,  :integer
    add_column :entities, :children_count,  :integer
    
    change_column :entities, :lft,  :integer, null: false
    change_column :entities, :rgt,  :integer, null: false
    #change_column :entities, :depth,  :integer, null: false
    #change_column :entities, :children_count,  :integer, null: false

    rename_column :entities, :left, :location_x
    rename_column :entities, :top, :location_y
  end

  def down
    remove_column :entities, :lft
    remove_column :entities, :rft
    remove_column :entities, :depth 
    remove_column :entities, :children_count 

    rename_column :entities, :location_x, :left 
    rename_column :entities, :location_y, :top 
  end
end
