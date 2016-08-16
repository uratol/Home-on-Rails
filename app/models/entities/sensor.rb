class Sensor < Device
  
  def shedule
    @shedule || (5.minutes unless respond_to? :watch)
  end  
  
  def get_driver_value
    raise "Override this method in driver module"
  end
  
  def poll
    store_value get_driver_value
  end

  def do_shedule
    poll
    super
  end
  
end
