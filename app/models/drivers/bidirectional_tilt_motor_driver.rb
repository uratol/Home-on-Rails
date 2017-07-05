# Драйвер для управления жалюзями и рафшторами, угол наклона ламелей в которых регулируется тем же двигателем, что и позиция открытия.
# Моторы управляются с помощью двух реле, которые должны быть созданы как подчинённые объекты с именами [имя]_up and [имя]_down соответственно

module BidirectionalTiltMotorDriver

  include BidirectionalMotorDriver

  def self.description
    "Virtual driver for facade blinds with tilt setting by bidirectional motor. Up and down motor relay entities must exists with [name]_up and [name]_down names respectively"
  end

  # Возвращает текущий угол наклона ламелей
  def tilt
    if thread_active? && tiltable?
      current_tilt = (relay_thread[:start_tilt] || data.tilt || min_tilt)
      current_tilt += tilt_velocity(relay_thread[:direction]) * (Time.now - relay_thread[:start_time])
      current_tilt.restrict_by_range(min_tilt, max_tilt)
    else
      data.tilt.to_f
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
    if tilt
      raise "Methods min_tilt, max_tilt, tilt_up_full_time, tilt_down_full_time must be defined" unless tiltable?
      tilt = tilt.restrict_by_range(min_tilt, max_tilt)
    end

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

    if tiltable?
      relay_thread[:start_tilt] = data.tilt if relay_thread && !relay_thread[:start_tilt]
      data.tilt = tilt
    end

    parent_remote_call(:set_position_and_tilt!, position, tilt)
  end

  # возвращает текущую позицию
  def position
    if respond_to?(:current_position)
      current_position
    else
      value
    end
  end

  # @!visibility private
  def on_finish_step(step)
    if tiltable?
      new_tilt = (relay_thread[:start_tilt] || data.tilt) + tilt_velocity(step.direction) * (Time.now - relay_thread[:start_time])
      relay_thread[:start_tilt] = new_tilt.restrict_by_range(min_tilt, max_tilt)
    end
  end

  # @!visibility private
  def on_stop
    data.tilt = tilt
  end

  def on_finish
    do_event(:at_finish)
  end

  private

  def calc_tilt_steps(new_tilt)
    direction = (new_tilt - tilt).sign
    return [] if direction == 0
    time = (new_tilt - tilt).to_f / tilt_velocity(direction)
    add_to_steps([], direction, time.abs)
  end

  def calc_tilt_and_position_steps(new_position, new_tilt)
    start_tilt = tilt
    start_position = position

    time_up_before_collapse = (max_tilt - start_tilt) * tilt_velocity(1)
    time_up_collapsed = (new_position - start_position) / velocity(1)
    position_up = start_position + (time_up_before_collapse + time_up_collapsed) * velocity(1)
    position_up = max if position_up > max
    time_up_reverse = (max_tilt - new_tilt) / tilt_velocity(-1).abs
    position_up += time_up_reverse * velocity(-1)
    up_full_time = time_up_before_collapse + time_up_collapsed + time_up_reverse


    time_down_before_collapse = (min_tilt - start_tilt) * tilt_velocity(-1)
    time_down_collapsed = (new_position - start_position) / velocity(-1)
    position_down = start_position + (time_down_before_collapse + time_down_collapsed) * velocity(-1)
    position_down = min if position_down < min
    time_down_reverse = (new_tilt - min_tilt) / tilt_velocity(1)
    position_down += time_down_reverse * velocity(1)
    down_full_time = time_down_before_collapse + time_down_collapsed + time_down_reverse

    up_error = (position_up - new_position).abs
    down_error = (position_down - new_position).abs

    path = if up_error == down_error
      up_full_time < down_full_time ? :up : :down
    else
      up_error < down_error ? :up : :down
    end

    start_direction, forward_time, reverse_time = (path == :up ?
          [1, time_up_before_collapse + time_up_collapsed, time_up_reverse] :
          [-1, time_down_before_collapse + time_down_collapsed, time_down_reverse])

    steps = add_to_steps([], start_direction, forward_time)
    add_to_steps(steps, -start_direction, reverse_time, new_position)



=begin
    steps = calc_steps_to_positions(new_position)

    return steps if steps.empty?

    new_tilt ||= tilt

    end_tilt = calc_end_tilt_for_steps(steps)
    tilt_diff = new_tilt - end_tilt
    tilt_direction = steps.last.direction != 0 ? -steps.last.direction : -tilt_diff.sign
    tilt_set_time = (tilt_diff / tilt_velocity(tilt_direction)).abs

    steps = add_to_steps(steps, -tilt_direction, tilt_set_time)
    add_to_steps(steps, tilt_direction, tilt_set_time, new_position)
=end
  end

  def calc_end_tilt_for_steps(steps)
    end_tilt = tilt || min_tilt
    steps.each do |step|
      end_tilt += tilt_velocity(step.direction) * step.delay
      end_tilt = end_tilt.restrict_by_range(min_tilt,max_tilt)
    end
    end_tilt
  end

  def tilt_velocity(direction)
    (max_tilt.to_f - min_tilt.to_f) / (direction == 1 ? tilt_up_full_time : tilt_down_full_time) * direction
  end

  def tiltable?
    min_tilt && max_tilt && tilt_up_full_time && tilt_down_full_time
  end

end
