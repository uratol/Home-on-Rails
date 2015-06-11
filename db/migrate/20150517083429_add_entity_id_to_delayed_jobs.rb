class AddEntityIdToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :entity_id, :integer
    add_index :delayed_jobs, [:entity_id, :queue]
  end
  
end
