module BidirectionalMotorDriver

  def extended(base)
    base.binary = false
  end

  def binary?
    false
  end

  def self.required_methods
    [:up_full_time, :down_full_time]
  end
  
  def set_driver_value(target_position)
    set_positions!(target_position) unless @stopping
  end

  def self.description
    "Virtual driver for bidirectional motor control. Up and down motor relay entities must exists with [name]_up and [name]_down names respectively" 
  end
  
  def current_position
    return value.to_f unless thread_active?
    distance = calc_position_offset(relay_thread[:start_time], Time.now, relay_thread[:direction])
    (relay_thread[:start_position] + distance).restrict_by_range(min,max)
  end

  def current_direction
    thread_active? ? relay_thread[:direction] : 0
  end
  
  def up!
    on!
  end

  def down!
    off!
  end
  
  def stop!(at_position)
    @stopping = true
    fire_event(:on_stop)
    write_value(at_position || current_position)
    stop_thread
  ensure
    @stopping = false
  end

  def contra_pause_time
    @contra_pause_time ||= 0.5.seconds
  end

  def contra_pause_time=(interval)
    @contra_pause_time = interval
  end
  
  # default 5% of full time moving
  def adjustment_percent
    @adjustment_percent ||= 5
  end

  def adjustment_percent=(value)
    @adjustment_percent = value
  end

  def set_positions!(*positions)
    return if @stopping
    start_steps!(calc_steps_to_positions(*positions))
  end

  protected

  MotorStep = Struct.new(:direction, :delay, :start_position, :finish_position)

  def up_motor
    @up_motor = nil if name_changed?
    @up_motor ||= send(name + '_up')
  end 
  
  def down_motor
    @down_motor = nil if name_changed?
    @down_motor ||= send(name + '_down')
  end 
  
  def stop_thread
    if thread_active? && Thread.current != relay_thread
      relay_thread.terminate
      relay_thread.join
      self.relay_thread = nil 
    end
  end

  private

  def start_steps!(steps)
    return if steps.empty?

    stop!(steps.last.finish_position)

    up_relay, down_relay = up_motor, down_motor

    start_position = current_position

    th = Thread.new do
      th[:start_position] = start_position
      th[:direction] = 0
      th[:start_time] = Time.now

      steps.each do |step|
        next if step.delay == 0
        now = Time.now
        th[:start_position] = step.start_position || (th[:start_position] + calc_position_offset(th[:start_time], now, th[:direction]))
        th[:start_time] = now
        th[:direction] = step.direction
        fire_event(:on_start_step, step)
        up_relay.set_driver_value(step.direction > 0 ? 1 : 0)
        down_relay.set_driver_value(step.direction < 0 ? 1 : 0)
        sleep(step.delay)
        fire_event(:on_finish_step, step)
      end
    end
    self.relay_thread = th
    th.priority = 10
  end

  def add_to_steps(steps, direction, time, finish_position = nil)
    last_step = steps.last
    if last_step.nil?
      start_position = current_position
    else
      start_position = last_step.finish_position
    end
    finish_position = finish_position || (start_position + velocity(direction) * time).restrict_by_range(min,max)

    if last_step.nil? || last_step.direction != direction
      if last_step && direction * last_step.direction == -1
        steps << MotorStep.new(0, contra_pause_time, start_position, start_position)
      end
      steps << MotorStep.new(direction, time, start_position, finish_position)
    else
      last_step.delay += time
      last_step.finish_position = finish_position
      steps
    end
  end

  def velocity(direction)
    (max - min).to_f / (direction == 1 ? up_full_time : direction == -1 ? down_full_time : 0) * direction
  end

  def fire_event(method_sym, *args)
    send(method_sym, *args) if respond_to? method_sym
  end


  def calc_steps_to_positions(*positions)
    prev_position = current_position
    prev_direction = current_direction

    steps = []
    [*positions].each do |position|
      delay = calc_delay(prev_position, position)
      direction = delay.sign
      delay = delay.abs
      delay += calc_adjustment_time(position) if direction != 0

      if prev_direction * direction == -1
        steps = add_to_steps(steps, 0, contra_pause_time, position)
      end

      steps = add_to_steps(steps, direction, delay, position)
      prev_position = position
      prev_direction = direction
    end
    steps
  end

  def calc_delay(source_position, target_position)
    delta_position = target_position - source_position
    full_time = delta_position > 0 ? up_full_time : down_full_time
    delta_position * full_time.to_f / (max - min)
  end

  def calc_position_offset(start_time, finish_time, direction)
    (finish_time - start_time).to_f / (direction > 0 ? up_full_time : down_full_time) * (max - min) * direction
  end
  
  def calc_adjustment_time(target_position)
    if target_position==max
      up_full_time
    elsif target_position==min  
      down_full_time
    else 0 end * adjustment_percent.to_f / 100    
  end

  def thread_active?
    relay_thread && relay_thread.alive?
  end

  def relay_thread
    $relay_threads = {} unless $relay_threads
    $relay_threads[id]
  end

  def relay_thread=(thread)
    $relay_threads = {} unless $relay_threads
    $relay_threads[id] = thread
  end
  
end  