class RenameEntityDataToAttrs < ActiveRecord::Migration
  def change
    add_column :entities, :attrs, :binary
  end
end
