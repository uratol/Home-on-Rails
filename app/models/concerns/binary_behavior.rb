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
    Thread.new do
      (args[:blink_count]||1).times do
        devices = args[:devices]
        [*devices].each do |e|
          v = e.on?
          e.set_driver_value !v
          sleep(0.2)
          e.set_driver_value v
          sleep(0.2)
        end
      end
      block_after.call if block_after
    end
  end

end