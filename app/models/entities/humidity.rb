# Датчик влажности

class Humidity < Sensor

  register_attributes min: 0, max: 100
  register_attributes caption_class: 'center-bottom-inner'

  def init
    super
    self.binary = false
    self.schedule = 1.minute
  end  

  def text
    "#{ value.try :round  } %"
  end

end
