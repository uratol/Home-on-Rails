class Button < Widget

  include ::ChangeBehavior
  include ::ActorBehavior

  def caption_style
    value ? 'top-center' : 'center'
  end
  
end