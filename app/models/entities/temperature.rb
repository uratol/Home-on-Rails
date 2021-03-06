# Датчик температуры

class Temperature < Sensor

  register_attributes min: -50, max: 100, caption_class: 'center-bottom-inner'

  def init
    super
    self.binary = false
    self.schedule = 30.seconds
  end  

  def text
    "#{ value.try :round,1  } \u00B0 C"
  end

end
