# Драйвер для управления жалюзями и рафшторами, угол наклона ламелей в которых регулируется тем же двигателем, что и позиция открытия.
# Моторы управляются с помощью двух реле, которые должны быть созданы как подчинённые объекты с именами [имя]_up and [имя]_down соответственно

module BidirectionalTiltMotorDriver

  include BidirectionalMotorDriver

  def self.description
    "Virtual driver for facade blinds with tilt setting by bidirectional motor. Up and down motor relay entities must exists with [name]_up and [name]_down names respectively"
  end

  # Возвращает текущий угол наклона ламелей
  def tilt
    if thread_active?
      current_tilt = (relay_thread[:start_tilt] || data.tilt.to_f)
      current_tilt += tilt_velocity(relay_thread[:direction]) * (Time.now - relay_thread[:start_time])
      current_tilt.restrict_by_range(min_tilt, max_tilt)
    else
      data.tilt.to_f || min_tilt
    end
  end

  # Запускает поток установки позиции, угол наклона ламелей в результате изменится
  def set_position! (position)
    super
  end

  # Запускает поток установки угла наклона ламелей, позиция в результате незначительно изменится
  def set_tilt!(tilt)
    set_position_and_tilt!(nil, tilt)
  end

  # Запускает поток установки позиции и угла наклона ламелей
  def set_position_and_tilt!(position, tilt)

    tilt = tilt.restrict_by_range(min_tilt, max_tilt) if tilt

    if position && tilt
      steps = calc_tilt_and_position_steps(position || self.position, tilt)
    elsif tilt
      steps = calc_tilt_steps(tilt)
    elsif position
      steps = calc_steps_to_positions(position)
    else
      return
    end

    start_steps!(steps)

#    relay_thread[:start_tilt] = data.tilt if relay_thread && !relay_thread[:start_tilt]
#    data.tilt = tilt

    parent_remote_call(:set_position_and_tilt!, position, tilt)
  end


  # @!visibility private
  def on_start_step(step)
    relay_thread[:start_tilt] = data.tilt unless relay_thread[:start_tilt]
  end

  # @!visibility private
  def on_finish_step(step)
    new_tilt = (relay_thread[:start_tilt]) + tilt_velocity(step.direction) * (Time.now - relay_thread[:start_time])
    new_tilt = new_tilt.restrict_by_range(min_tilt, max_tilt)
    relay_thread[:start_tilt] = new_tilt
  end

  # @!visibility private
  def on_stop
    remember_tilt
  end

  # @!visibility private
  def on_start
    remember_tilt
  end

  # @!visibility private
  def on_before_finish
    if relay_thread && (data.tilt.to_f - relay_thread[:start_tilt]).abs > (max_tilt - min_tilt)/100
      remember_tilt(relay_thread[:start_tilt])
    end
  end

  # @!visibility private
  def remember_tilt(tilt = nil)
    data.tilt = tilt || self.tilt.restrict_by_range(min_tilt, max_tilt)
  end

  # @!visibility private
  def calc_tilt_steps(new_tilt)
    direction = (new_tilt - tilt).sign
    return [] if direction == 0
    time = (new_tilt - tilt).to_f / tilt_velocity(direction)
    add_to_steps([], direction, time.abs)
  end

  # @!visibility private
  def calc_tilt_and_position_steps(new_position, new_tilt)
    start_tilt = tilt
    start_position = position

    time_up_before_collapse = (max_tilt - start_tilt) / tilt_velocity(1)
    time_up_collapsed = (new_position - start_position) / velocity(1)
    time_up_reverse = (max_tilt - new_tilt) / tilt_velocity(-1).abs
    up_full_time = time_up_before_collapse + time_up_collapsed + time_up_reverse


    time_down_before_collapse = (min_tilt - start_tilt) / tilt_velocity(-1)
    time_down_collapsed = (new_position - start_position) / velocity(-1)
    time_down_reverse = (new_tilt - min_tilt) / tilt_velocity(1)
    down_full_time = time_down_before_collapse + time_down_collapsed + time_down_reverse

    start_direction, forward_time, reverse_time = ( (up_full_time >= 0 && (up_full_time < down_full_time || down_full_time < 0)) ?
          [1, time_up_before_collapse + time_up_collapsed, time_up_reverse] :
          [-1, time_down_before_collapse + time_down_collapsed, time_down_reverse])

    steps = add_to_steps([], start_direction, forward_time)
    add_to_steps(steps, -start_direction, reverse_time)
  end

  def tilt_velocity(direction)
    (max_tilt.to_f - min_tilt.to_f) / (direction == 1 ? tilt_up_full_time : tilt_down_full_time) * direction
  end

end
