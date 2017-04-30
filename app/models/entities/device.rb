# Базовый класс для всех устройств, которым соответствует какое-либо оборудование: датчики, реле, моторы и т.д.

class Device < Entity
  include ChangeBehavior

  def init
    super
    @binary = true
  end  

end
