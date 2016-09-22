module EntityBehaviorHelpers

  def options opt
    opt.each do |k,v|
      send k.to_s+'=', v
    end
  end
  
  def wait_for interval = 1.second, &block
    at interval.from_now, &block 
  end
  
  alias_method :delay, :wait_for

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
  
  # Returns sunrise time
  def sunrise_time
    Clock.sunrise_time.in_time_zone
  end

  # Returns sunset time
  def sunset_time
    Clock.sunset_time.in_time_zone
  end

  # Sends email to user/users
  # ==== Attributes
  # *+body+ - body text
  # *+options+ 
  # ==== Options
  # *+from+ - sender email, default: smtp user name in settings
  # *+to+ - recepients, can be email string or array of email strings or +:admins+ (all admins) or +:all+ (all users). Default: all users
  # *+subject+ - subject of mail, default: title of current entity
  def mail body, options = {}
    options.reverse_merge! subject: caption
    HomeMailer.send_mail(body, options).deliver_now
  end
 
  def blink args = {}, &block_after
    args[:devices] ||= self
    args[:sender] ||= self
    BinaryBehavior.blink args, &block_after
  end
  
  def log &block
    Rails.logger.debug yield 
  end
  
end