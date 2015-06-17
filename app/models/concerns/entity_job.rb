class EntityJob < Delayed::Job
  belongs_to :entity
  
  def to_s
    "#{ queue } at #{ run_at }"
  end
end
