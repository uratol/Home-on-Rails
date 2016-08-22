class Boiler < Actor
  register_stored_attributes :pwm_power
  register_attributes caption_class: 'center-bottom-inner' 

  def init
    super
    @shedule = 30.seconds
  end  
  
  def pwm_power=(power)
    raise 'Shedule must be set for pwm power' unless shedule
    
    super
    save!
    return power
  end
  
  def do_shedule
    self.on = average_value(shedule * 10) < pwm_power if pwm_power
    super
  end
  
  def text
    if pwm_power
      "#{ (pwm_power * 100).round }%"
    else
      on? ? 'ON' : 'OFF'  
    end
  end
    
end