class EntityJob < Delayed::Job
  Delayed::Worker.destroy_failed_jobs = false

  belongs_to :entity
  
  def to_s
    "#{ queue } at #{ run_at }"
  end
end
