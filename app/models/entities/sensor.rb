class Sensor < Device
  
  def shedule
    @shedule || (5.minutes unless respond_to? :watch)
  end  
  
  def get_driver_value
    raise "Override this method in driver module"
  end
  
  def poll
    v = get_driver_value
    store_value v if v
  end

  def do_shedule
    poll
    super
  end
  
end
