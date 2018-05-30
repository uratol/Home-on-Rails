class Select < Widget
  register_attributes min: nil, max: nil

  def binary
    false
  end

  register_required_methods :select
  register_attributes caption_class: 'center-bottom-inner'
end