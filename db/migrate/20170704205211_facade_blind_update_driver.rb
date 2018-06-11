class FacadeBlindUpdateDriver < ActiveRecord::Migration.respond_to?(:[]) ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def up
    execute("update entities set driver='bidirectional_tilt_motor' where type='FacadeBlind' and driver='bidirectional_motor'")
  end

  def down
    execute("update entities set driver='bidirectional_motor' where type='FacadeBlind' and driver='bidirectional_tilt_motor'")
  end
end
