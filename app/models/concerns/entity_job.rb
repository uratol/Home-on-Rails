class EntityJob < Delayed::Job
  belongs_to :entity
end
