module ActorBehavior

  def set_driver_value v
    raise "Override this method in driver module"
  end
  
  protected

  def init
    super
    at_click{switch} unless events.assigned? :at_click
  end
  
end
