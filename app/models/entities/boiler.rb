class Boiler < Actor
  register_attributes caption_class: 'center-bottom-inner' 

  def text
    data.text || (on? ? 'ON' : 'OFF')
  end
end