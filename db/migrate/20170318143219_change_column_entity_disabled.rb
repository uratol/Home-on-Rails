class ChangeColumnEntityDisabled < ActiveRecord::Migration
  def up
    execute("update entities set disabled='f' where disabled is null")
    change_column :entities, :disabled, :boolean, null: false, default: false
  end
end
