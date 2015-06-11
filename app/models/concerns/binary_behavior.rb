module BinaryBehavior
  def on?
    value && value!=0
  end

  def off?
    !on?
  end

  def opposite_value 
    1-(value||0)
  end

  def switch!
    write_value opposite_value
  end

  def on! options = {}
    if off? 
      switch! 
      wait_for(options[:delay]).off! if options[:delay]  
    end
    return value  
  end

  def on= v
    if v && v!=0 then on! else off! end
  end

  def off! options = {}
    if on? 
      switch!
      wait_for(options[:delay]).off! if options[:delay]
    end  
    return value  
  end

  def off= v
    if v && v!=0 then off! else on! end
  end
end