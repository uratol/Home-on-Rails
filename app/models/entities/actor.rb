class Actor < Device
  include ActorBehavior
  
  def startup
    #set_driver_value invert_driver_value(value)
    super
  end
end
