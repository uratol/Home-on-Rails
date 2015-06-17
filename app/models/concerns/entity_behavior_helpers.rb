module EntityBehaviorHelpers

  def options opt
    opt.each do |k,v|
      send k.to_s+'=', v
    end
  end
  
  def wait_for interval, &block
    at interval.from_now, &block 
  end

  def at run_time, &block
    opt = {at: run_time, method: :run_at, source_row: (block.source_location.second if block)}
    EntityJobHandler.new self, opt
  end
  
  def every run_interval, options = {}, &block
    options[:run_interval] = run_interval
    if block
      options.merge!({method: :every, source_row: block.source_location.second })
      events.add :every, block, options
    end  
    EntityJobHandler.new self, options 
  end
  
  def cancel job_name = nil
    cond = {entity_id: self.id}
    cond[:queue] = job_name if job_name
    EntityJob.delete_all cond
  end
  
  def sunrise_time
    Clock.sunrise_time
  end

  def sunset_time
    Clock.sunset_time
  end
  
  def day
    1.day
  end
  
  def week
    1.week
  end
  
  def blink args = {}, &block_after
    args[:devices] ||= self
    args[:sender] ||= self
    BinaryBehavior.blink args, &block_after
  end
  
end