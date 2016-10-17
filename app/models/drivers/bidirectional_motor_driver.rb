module BidirectionalMotorDriver
  
  def self.required_methods
    [:up_full_time, :down_full_time]
  end
  
  def set_driver_value target_position 
    start(target_position)
  end
  
  
  def self.description
    "Virtual driver for bidirectional motor control. Up and down motor relay entities must exists with [name]_up and [name]_down names respectively" 
  end
  
  def current_position
    if current_direction != 0
      delay = (Time.now.to_f - relay_thread[:start_time].to_f) / (relay_thread[:delay] > 0 ? up_full_time : down_full_time) * (max - min)
      pos = relay_thread[:start_position] + delay * relay_thread[:delay].sign
      pos = min.to_f if pos < min
      pos = max.to_f if pos > max
      pos
    else
      value  
    end
  end
  
  def current_direction
    if relay_thread && relay_thread.alive?
      relay_thread[:delay].sign
    else
      0
    end
  end
  
  def up!
    on!
  end

  def down!
    off!
  end
  
  def stop!
    if current_direction != 0
      @stopping = true
      write_value current_position
    end
  ensure  
    @stopping = false
  end

  def contra_pause_time
    @contra_pause_time ||= 0.5.seconds
  end

  def contra_pause_time= interval
    @contra_pause_time = interval
  end
  
  # default 5% of full time moving
  def adjustment_percent
    @adjustment_percent ||= 5
  end

  def adjustment_percent= value
    @adjustment_percent = value
  end
  
  protected

  def up_motor
    @up_motor = nil if name_changed?
    @up_motor ||= send(name + '_up')
  end 
  
  def down_motor
    @down_motor = nil if name_changed?
    @down_motor ||= send(name + '_down')
  end 
  
  def stop_thread
    result = current_position
    if current_direction != 0 
      relay_thread.terminate
      relay_thread.join
      self.relay_thread = nil 
    end
    result
  end  
  
  def start(target_position)
      curr_pos = current_position
      
      delay = calc_delay(curr_pos, target_position)

      if delay > 0
        start_relay, stop_relay = up_motor, down_motor
      else 
        start_relay, stop_relay = down_motor, up_motor
      end
  
      stop_relay.set_driver_value(0)
      if delay == 0
        start_relay.set_driver_value(0)
        stop_thread
        return
      end

      contra_delay = current_direction * delay < 0 ? contra_pause_time : 0
#      puts "current_direction: #{ current_direction }; delay: #{ delay }; relay_thread: #{ relay_thread }; relay_thread.alive?: #{ relay_thread.alive? if relay_thread}" 
#      byebug if delay>0
      stop_thread
      self.relay_thread = Thread.new(start_relay, delay, calc_adjustment_time(curr_pos, target_position), contra_delay) do |relay, delay, adjustment_time, contra_delay|
        sleep(contra_delay) if contra_delay > 0 
        start_relay.set_driver_value(1)
        sleep(delay.abs + adjustment_time)
        relay.set_driver_value(0)
      end
      relay_thread[:start_time] = Time.now
      relay_thread[:delay] = delay
      relay_thread[:start_position] = curr_pos
      relay_thread.priority = 10
  end
  
  private
  
  def calc_delay(source_position, target_position)
    return 0 if (@stopping ||= false)
        
    delta_position = target_position - source_position
    full_time = if delta_position > 0 then up_full_time else down_full_time end
    return delta_position * full_time.to_f / (max - min)
  end
  
  def calc_adjustment_time(source_position, target_position)
    if target_position==max
      up_full_time
    elsif target_position==min  
      down_full_time
    else 0 end * adjustment_percent.to_f / 100    
  end

  def relay_thread
    $relay_threads = {} unless $relay_threads
    $relay_threads[id]
  end

  def relay_thread= thread
    $relay_threads = {} unless $relay_threads
    $relay_threads[id] = thread
  end
  
end  