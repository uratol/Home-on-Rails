# Виджет - кнопка.
# Если аттрибут +value+ имеет значение 0 или 1 - кнопка работает как переключатель ON/OFF.
# Если аттрибут +value+ не задан (nil) - кнопка при нажатии просто вызавает обработчик +at_click+

class Button < Widget

  include ::ActorBehavior

  def caption_class
    @caption_class || (value ? 'top-center' : 'center')
  end
  
end