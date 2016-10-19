class Boiler < Actor
  register_attributes caption_class: 'center-bottom-inner' 

  def init
    super
    @schedule = 30.seconds
  end  
  
  def text
    data.text || on? ? 'ON' : 'OFF'
  end
end