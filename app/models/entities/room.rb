class Room < Placement

  alias_attribute :daylight, :power
  register_attributes caption_class: 'left-top-inner' 
=begin  
  def presense
    value!=0
  end
  
  def presense= v
    value= if v || v==0 then 0 else 1 end
  end

  def presense!
    presense=true
  end
  
  def absense
    !presense
  end
  
  def absense!
    presense=false
  end
=end  
  
  def illumination
    lamplight + (Clock.night? ? 0 : (daylight || 100)/100)
  end

  def lamplight
    lamps = descendants.where(type: ([Light]+Light.descendants).map(&:to_s) ) # select{|e| e.is_a? Light}

    sum_power = lamps.inject(0){|s,e| s+(e.power||0) }
    if sum_power != 0
      lamps.inject(0){|s,e| s+(e.value||0)*(e.power||0) }/sum_power
    else
      0
    end
  end

  def brightness
    # for a brigthness filter in views. 100 - normal
    result = ((illumination || 1)*100)
    result = 25 + result * 0.75
    result = 130 if result > 130
    result.round
  end
  
  def data_attributes
    super + [:brightness]
  end

  private

end