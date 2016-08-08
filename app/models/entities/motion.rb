class Motion < Sensor
  def last_motion_time
    wc_motion.indications.where(value: 0).limit(1).order('created_at DESC').first.created_at
  end
  
  def last_motion_interval
    Time.now - last_motion_time
  end

  def invert_driver_value?
    is_a? GpioDriver
  end
  
end
