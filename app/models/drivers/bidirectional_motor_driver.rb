module BidirectionalMotorDriver
  
  def self.required_methods
    [:up_full_time, :down_full_time]
  end
  
  def set_driver_value v
    delay = calc_delay(current_position.round, v)
    stop_thread
    start(delay)
  end
  
  
  def self.description
    "Virtual driver for bidirectional motor control. Up and down motor relay entities must exists with [name]_up and [name]_down names respectively" 
  end
  
  def current_position
    if current_direction != 0
      delay = (Time.now - $relay_thread[:start_time]) / ($relay_thread[:delay] > 0 ? up_full_time : down_full_time) * (max - min)
      $relay_thread[:start_position] + delay * $relay_thread[:delay].sign
    else
      value  
    end
  end
  
  def current_direction
    if $relay_thread && $relay_thread.alive?
      $relay_thread[:delay].sign
    else
      0
    end
  end
  
  def up!
    write_value max
  end

  def down!
    write_value min
  end
  
  def stop!
#    stop_thread
    write_value current_position.round
  end
  
  protected

  def up_motor
    @up_motor ||= send(name + '_up')
  end 
  
  def down_motor
    @down_motor ||= send(name + '_down')
  end 
  
  def stop_thread
    result = current_position
    if $relay_thread && $relay_thread.alive?
      $relay_thread.terminate
      $relay_thread.join
    end
    result
  end  
  
  def start(delay)
      direction = delay.sign
      if delay > 0
        start_relay, stop_relay = up_motor, down_motor
      else 
        start_relay, stop_relay = down_motor, up_motor
      end
  
      stop_relay.set_driver_value(0)
      if delay == 0
        start_relay.set_driver_value(0)
        return
      end
  
      start_relay.set_driver_value(1)
      start_time = Time.now
      $relay_thread = Thread.new(start_relay, delay, start_time) do |relay, delay, start_time|
        sleep(delay.abs + start_time.to_f - Time.now.to_f)
        relay.set_driver_value(0)
      end
      $relay_thread[:start_time] = start_time
      $relay_thread[:delay] = delay
      $relay_thread[:start_position] = value
      $relay_thread.priority = 10
  end

  private
  
  def calc_delay(source_position, target_position)
    delta_position = target_position - source_position
    full_time = if delta_position > 0 then up_full_time else down_full_time end
    return delta_position * full_time.to_f / (max - min)
  end
  
  
end  