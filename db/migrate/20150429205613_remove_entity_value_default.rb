class RemoveEntityValueDefault < ActiveRecord::Migration
  def change
    change_column_default(:entities, :value, nil)
  end
end
