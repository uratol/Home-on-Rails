class Door < Sensor
  alias_method :opened?, :on? 
  alias_method :closed?, :off?
end
