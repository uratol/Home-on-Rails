class Sensor < Device
  
  def get_driver_value
    raise "Override this method in driver module"
  end
  
end
