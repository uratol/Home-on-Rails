# Базовый класс для всех устройств, которым соответствует какое-либо оборудование: датчики, реле, моторы и т.д.

class Device < Entity

  def init
    super
    @binary = true
  end  

end
