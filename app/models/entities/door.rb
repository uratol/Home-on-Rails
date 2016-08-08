class Door < Sensor
  alias_method :opened?, :off? 
  alias_method :closed?, :on?
  
  def init
    super
    invert_value = true if self.is_a? GpioDriver 
  end
  
end
