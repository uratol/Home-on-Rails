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
    switch! if off? 
    wait_for(options[:delay]).off! if options[:delay]  
    return value  
  end

  def on= v
    if v && v!=0 then on! else off! end
  end

  def off! options = {}
    switch! if on? 
    wait_for(options[:delay]).on! if options[:delay]
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
          [*devices].each{|e| e.set_driver_value(if j==0 then 1 - e.value else e.value end)}
          sleep(delay)
        end
      end
      if block_after
        if args[:sender]
          args[:sender].instance_eval(&block_after) 
        else
          block_after.call  
        end
      end
    end
  end
  
  def average_value(interval)
    to = Time.now
    from = to - interval
    first_indication = indication_at(from)
    if first_indication
      first_indication.created_at = from
    else
      first_indication = Indication.new(created_at: from, value: 0)
    end
    
    arr = [first_indication] 
    arr += indications.where('created_at between ? and ?', from, to).order(:created_at).to_a 
    arr << Indication.new(created_at: to, value: value)
    
    prev_indication = nil
    sum  = 0
    arr.each_with_index do |ind, i|
      sum += prev_indication.value * (ind.created_at - prev_indication.created_at) if prev_indication
      prev_indication = ind
    end
    return sum / (to - from)  
  end

  def do_schedule
    self.on = average_value(schedule * 10) < pwm_power if pwm_power
    super
  end

end