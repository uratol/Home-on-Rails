class Device < Entity
  include ChangeBehavior

  validate :driver_valid?
  before_save :default_values

  def init
    super
    @binary = true
  end  

  private

  def driver_valid?
    self.driver = nil if driver==''
    if driver && !Entity.drivers_names.include?(driver.to_s)
      errors.add(:driver, "Driver \"#{ driver }\" is not valid")
    end
  end
  
  def default_values
    self.value ||= 0
  end
    
end
