module CssHelper
  def default_style(entity)
    "filter: brightness(#{ entity.brightness }%" if entity.respond_to? :brightness
  end
end