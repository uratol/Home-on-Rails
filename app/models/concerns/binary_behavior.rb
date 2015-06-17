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

  def switch! options = {}
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
  
  def self.blink args = {}, &block_after
    delay = args[:delay] || 0.2
    devices = args[:devices]
    
    Thread.new do
      (args[:times]||1).times do |i|
        2.times do |j|
          [*devices].each{|e| e.set_driver_value(if j==0 then e.off? else e.on? end)}
          sleep(delay)
        end
      end
      if block_after
        if args[:sender]
          args[:sender].instance_eval &block_after 
        else
          block_after.call  
        end
      end
    end
  end

end