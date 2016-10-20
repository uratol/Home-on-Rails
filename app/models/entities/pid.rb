##
# Пропорциональный интегрально-дифференциальный регулятор
# Используется для управления нагрузкой
# value содержит текущую мощность

# реккурентная формула
# u(t) = u(t — 1) + P (t) + I (t) + D (t);
# P (t) = Kp * {e (t) — e (t — 1)};
# I (t) = Ki * e (t);
# D (t) = Kd * {e (t) — 2 * e (t — 1) + e (t — 2)};

class Pid < Widget
  register_attributes kP: 1, kI: 0.1, kD: 0.1, min_power: 0, max_power: 1
  
  register_required_methods :input_value, :target_value
  
  def init
    super
    @schedule = 30.seconds
  end  
  
  def do_schedule
    e = cast_value(target_value.to_f) - cast_value(input_value.to_f)

    #byebug
    prev_indication = last_indication
    #prev_time = prev_indication.created_at
    prev_value = prev_indication.try(:value) || 0

    e_previous = data.e_previous || 0
    e_previous2 = data.e_previous2 || 0
    
    p = kP * (e - e_previous)
    i = kI * e
    d = kD * (e - 2 * e_previous + e_previous2)
    
    self.value = trunc_power(prev_value + p + i + d)
    
    data.e_previous2 = e_previous
    data.e_previous = e
    write_value(self.value)
    
    super
    return value
  end
  
  private
  
  def reset
    self.value, data.e_previous, data.e_previous2 = 0
  end
  
  def cast_value v
    if v.is_a? Entity then v.value else v.to_f end
  end
    
  def trunc_power v
    v ||= 0
    v < min_power ? min_power : v > max_power ? max_power : v
  end
  
end