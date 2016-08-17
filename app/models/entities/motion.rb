class Motion < Sensor
  register_attributes caption_class: 'center-bottom-inner' 
  include ActionView::Helpers::DateHelper
  
  def last_motion_time
    if value == 1
      Time.now
    else
      last_indication_time(0)
    end 
    #wc_motion.indications.where(value: ).limit(1).order('created_at DESC').first.created_at
  end
  
  def last_motion_interval
    Time.now - last_motion_time
  end

  def invert_driver_value?
    is_a? GpioDriver
  end
  
  def text
    distance_of_time_in_words_to_now(last_motion_time)
  end
  
end
