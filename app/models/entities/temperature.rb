class Temperature < Sensor

  register_attributes caption_class: 'center-bottom-inner' 

  def init
    super
    self.binary = false
    self.schedule = 30.seconds
  end  

  def text
    "#{ value.try :round,1  } \u00B0 C"
  end

  private
  
  def on?
  end   

  def off?
  end

    
end
