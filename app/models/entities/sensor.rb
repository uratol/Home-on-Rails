# Базовый класс для всех устройств-датчиков.
# По расписанию опрашивает датчик и сохраняет значение в +value+
# Расписание задаётся в атрибуте +schedule+

class Sensor < Device

  # @!visibility private
  def get_driver_value
    raise "Override this method in driver module" if driver
  end

  # Опрашивает датчик и сохраняет значение в +value+
  def poll
    v = get_driver_value
    store_value v if v
  end

  # @!visibility private
  def do_schedule
    poll
    super
  end
  
end
