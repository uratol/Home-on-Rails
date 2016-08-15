class Temperature < Sensor

  def init
    super
    @binary = false
  end  
  
  private
  
  def on?
  end   

  def off?
  end
    
end
