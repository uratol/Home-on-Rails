class AddWidtHaightToEntity < ActiveRecord::Migration.respond_to?(:[]) ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    add_column :entities, :width, :int
    add_column :entities, :height, :int
  end
end
