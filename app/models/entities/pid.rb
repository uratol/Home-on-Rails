##
# Пропорциональный интегрально-дифференциальный регулятор.
# Используется для управления нагрузкой.
# Аттрибут +value+ содержит текущую мощность, которая пересчитывается по расписанию, указанному в +schedule+

# Используется реккурентная формула
# u(t) = u(t — 1) + P (t) + I (t) + D (t);
# P (t) = Kp * {e (t) — e (t — 1)};
# I (t) = Ki * e (t);
# D (t) = Kd * {e (t) — 2 * e (t — 1) + e (t — 2)};

class Pid < Widget
  # Ключевые коэффициенты для регулятора
  register_attributes kP: 0.5, kI: 0.1, kD: 0.1, min: 0, max: 1

  register_attributes caption_class: 'center-bottom-inner'

  register_required_methods :input_value, :target_value
  
  def init
    super
    self.schedule = 30.seconds
  end  
  
  def do_schedule
    target_value_cached = target_value

    if target_value_cached
      e = target_value_cached.to_f - input_value.to_f

      prev_indication = last_indication
      prev_value = prev_indication.try(:value) || 0

      e_previous = data.e_previous || 0
      e_previous2 = data.e_previous2 || 0

      p = kP * (e - e_previous)
      i = kI * e
      d = kD * (e - 2 * e_previous + e_previous2)

      transaction do
        data.e_previous2 = e_previous
        data.e_previous = e
        write_value(prev_value + p + i + d)
      end
    else
      reset
      save!
    end

    super
  end

  def text
    "#{ caption } #{(to_f * 100).round }%, #{ input_value.to_f } => #{ target_value.to_f }"
  end

  private
  
  def reset
    self.value = min
    data.e_previous = data.e_previous2 = 0
  end

end