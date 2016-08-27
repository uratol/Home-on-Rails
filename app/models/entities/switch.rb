class Switch < Sensor

  def invert_driver_value?
    is_a? GpioDriver
  end
  
end
