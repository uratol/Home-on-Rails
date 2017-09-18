# Драйвер для управления двунаправленным мотором
# Моторы управляются с помощью двух реле, которые должны быть созданы как подчинённые объекты с именами [имя]_up and [имя]_down соответственно
module BidirectionalMotorDriver

  def self.description
    "Virtual driver for bidirectional motor control. Up and down motor relay entities must exists with [name]_up and [name]_down names respectively"
  end


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

  def position
    return value.to_f unless thread_active?
    distance = calc_position_offset(relay_thread[:start_time], Time.now, relay_thread[:direction])
    (relay_thread[:start_position] + distance).restrict_by_range(min,max)
  end

  alias_method :current_position, :position

  # текущее направление, 1 - вверх, -1 - вниз, 0 - стоит
  def direction
    thread_active? ? relay_thread[:direction] : 0
  end

  alias_method :current_direction, :direction
  
  def up!
    parent_remote_call(:on!)
    on!
  end

  def down!
    parent_remote_call(:off!)
    off!
  end
  
  def stop!(at_position = nil)
    parent_remote_call(:stop!) unless at_position
    @stopping = true
    up_motor.set_driver_value(0)
    down_motor.set_driver_value(0)
    write_value(at_position || current_position)
    if thread_active? || at_position.nil?
      fire_event(:on_stop)
      fire_event(:on_finish)
    end
    stop_thread
  ensure
    @stopping = false
  end

  def on_finish
    do_event(:at_finish)
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
    parent_remote_call(:set_positions!, *positions)
    start_steps!(calc_steps_to_positions(*positions))
  end

  alias_method :set_position!, :set_positions!

  def velocity(direction = current_direction)
    (max - min).to_f / (direction == 1 ? up_full_time : down_full_time) * direction
  end

  def time_to_position(position)
    delta = current_position - position
    (delta / velocity(delta < 0 ? 1 : -1)).abs + (current_direction * -delta > 0 ? contra_pause_time : 0)
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

    start_position = current_position
    stop!(steps.last.finish_position)

    return if steps.empty?

    up_relay, down_relay = up_motor, down_motor
    up_value, down_value = -1
    time_lag_start = nil

    fire_event(:on_start)
    th = Thread.new do

      th[:start_position] = start_position
      th[:direction] = 0
      th[:start_time] = Time.now

      steps.each do |step|
        next if step.delay == 0
        return if @stopping
        now = Time.now
        th[:start_position] = step.start_position || (th[:start_position] + calc_position_offset(th[:start_time], now, th[:direction]))
        th[:start_time] = now
        th[:direction] = step.direction
        fire_event(:on_start_step, step)

        up_value_previous = up_value
        down_value_previous = down_value

        up_value = step.direction > 0 ? 1 : 0
        down_value = step.direction < 0 ? 1 : 0

        up_relay.set_driver_value(up_value) if up_value != up_value_previous
        down_relay.set_driver_value(down_value) if down_value != down_value_previous

        now = Time.now
        time_lag = now - (time_lag_start || now)
        sleep(step.delay - time_lag)

        time_lag_start = Time.now

        fire_event(:on_finish_step, step)
      end
      up_relay.set_driver_value(0)
      down_relay.set_driver_value(0)
      fire_event(:on_before_finish)
      self.relay_thread = nil
      fire_event(:on_finish)
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
        steps = add_to_steps(steps, 0, contra_pause_time, prev_position)
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

  # Проверяет, если родитель - удалённый сервер - вызывает метод *method_name* на удалённом сервере
  def parent_remote_call(method_name, *args)
    if parent.is_a?(Server) && parent.address.present? && !remote_call?
      parent.execute_remote_method(name, method_name, *args)
    end
  end

end  