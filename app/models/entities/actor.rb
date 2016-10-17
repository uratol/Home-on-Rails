class Actor < Device
  include ActorBehavior
  
  def sturtup
    #set_driver_value invert_driver_value(value)
    super
  end
end
