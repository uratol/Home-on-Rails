class Slider < Widget
  register_attributes min: 0, max: 100, step: 1, orientation: :gorizontal, caption_class: 'center-bottom-inner'
  
  def binary
    false
  end
  
  def text
    human_value
  end
  
  def human_value
    return unless value
    (step == step.round ? value.round : value).to_s
  end
end