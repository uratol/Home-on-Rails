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
  
  def cancel job_name
    EntityJob.delete_all entity_id: self.id, queue: job_name 
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
end