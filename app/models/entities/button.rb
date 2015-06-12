class Button < Widget

  include ::ChangeBehavior
  include ::ActorBehavior

  def caption_class
    @caption_class || (value ? 'top-center' : 'center')
  end
  
end