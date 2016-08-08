class Door < Sensor
  alias_method :opened?, :off? 
  alias_method :closed?, :on?
  
  protected
  
  def invert_driver_value?
    is_a? GpioDriver
  end
  
end
