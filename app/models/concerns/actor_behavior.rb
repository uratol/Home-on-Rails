module ActorBehavior
  
  protected

  def init
    super
    at_click{switch!} unless events.assigned? :at_click
  end
  
end
