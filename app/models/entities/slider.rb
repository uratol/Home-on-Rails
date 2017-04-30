# Виджет "Ползунок"
class Slider < Widget
  include ::ChangeBehavior
  register_attributes min: 0, max: 100, step: 1, orientation: :gorizontal, caption_class: 'center-bottom-inner' 
  
  def binary
    false
  end
  
  def text
    human_value
  end
  
  def human_value
    value.round.to_s if value
  end
  
end