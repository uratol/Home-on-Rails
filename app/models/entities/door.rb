class Door < Sensor
  alias_method :opened?, :off? 
  alias_method :closed?, :on?
end
