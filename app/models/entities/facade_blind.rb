class FacadeBlind < Device

  register_attributes :min_tilt, :max_tilt, :tilt_up_full_time, :tilt_down_full_time

  def init
    super
    self.binary = false
  end

  def tilt_range=(r)
    self.min_tilt, self.max_tilt = r.first, r.last
  end

  def position_range=(r)
    self.min, self.max = r.first, r.last
  end

  def set_position! (position)
    set_position_and_tilt!(position, nil)
  end

  def tilt
    if thread_active?
      current_tilt = (relay_thread[:start_tilt] || data.tilt || min_tilt)
      current_tilt += tilt_velocity(relay_thread[:direction]) * (Time.now - relay_thread[:start_time])
      current_tilt.restrict_by_range(min_tilt, max_tilt)
    else
      data.tilt
    end
  end

  def set_tilt!(tilt)
    set_position_and_tilt!(nil, tilt)
  end

  def set_position_and_tilt!(position, tilt)
    if tilt && !tiltable?
      raise "Methods min_tilt, max_tilt, tilt_up_full_time, tilt_down_full_time must be defined"
    end
    tilt = tilt.restrict_by_range(min_tilt, max_tilt) if tilt
    if position
      steps = calc_tilt_and_position_steps(position || self.position, tilt)
    else
      steps = calc_tilt_steps(tilt)
    end

    start_steps!(steps)
    if tilt
      relay_thread[:start_tilt] = data.tilt if relay_thread && !relay_thread[:start_tilt]
      data.tilt = tilt
    end

  end

  def position
    if respond_to?(:current_position)
      current_position
    else
      value
    end
  end

  def on_finish_step(step)
    if tiltable?
      new_tilt = (relay_thread[:start_tilt] || data.tilt) + tilt_velocity(step.direction) * (Time.now - relay_thread[:start_time])
      relay_thread[:start_tilt] = new_tilt.restrict_by_range(min_tilt, max_tilt)
    end
  end

  def on_stop
    data.tilt = tilt
  end

  private

  def calc_tilt_steps(new_tilt)
    direction = (new_tilt - tilt).sign
    return [] if direction == 0
    time = (new_tilt - tilt).to_f / tilt_velocity(direction)
    add_to_steps([], direction, time.abs)
  end

  def calc_tilt_and_position_steps(new_position, new_tilt)
    steps = calc_steps_to_positions(new_position)

    return steps if steps.empty? || tilt == new_tilt

    new_tilt ||= tilt

    end_tilt = calc_end_tilt_for_steps(steps)
    tilt_diff = new_tilt - end_tilt
    tilt_direction = steps.last.direction != 0 ? -steps.last.direction : -tilt_diff.sign
    tilt_set_time = (tilt_diff / tilt_velocity(tilt_direction)).abs

    steps = add_to_steps(steps, -tilt_direction, tilt_set_time)
    add_to_steps(steps, tilt_direction, tilt_set_time, new_position)
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