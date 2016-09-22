class Boiler < Actor
  register_attributes caption_class: 'center-bottom-inner' 

  def init
    super
    @schedule = 30.seconds
  end  
  
  def text
    if data.pwm_power
      "#{ (data.pwm_power * 100).round }%"
    else
      on? ? 'ON' : 'OFF'  
    end
  end
end