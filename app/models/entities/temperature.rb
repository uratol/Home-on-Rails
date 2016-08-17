class Temperature < Sensor

  register_attributes caption_class: 'center-bottom-inner' 

  def init
    super
    @binary = false
  end  

  def text
    "#{ value.round(1) } \u00B0 C"
  end

  
  private
  
  def on?
  end   

  def off?
  end

    
end
