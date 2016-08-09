class Door < Sensor
  alias_method :opened?, :on? 
  alias_method :closed?, :off?
  
  protected
  
  def invert_driver_value?
    is_a? GpioDriver
  end
  
end
