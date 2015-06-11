class Indication < ActiveRecord::Base
  belongs_to :entity
  alias_attribute :dt, :created_at

  def self.indication_at e, dt
    self.where(entity: e).where('created_at<=?',dt).limit(1).order('created_at DESC').take
  end

end
