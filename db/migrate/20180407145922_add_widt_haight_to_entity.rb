class AddWidtHaightToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :width, :int
    add_column :entities, :height, :int
  end
end
