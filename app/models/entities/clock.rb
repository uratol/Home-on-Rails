class Clock < Widget
  require 'sun_times'
  
  @@sun_time = nil
  
  def time
    Time.now
  end

  def self.night?
    now = Time.now
    return (now < sunrise_time || now > sunset_time)
  end
  
  def self.day?
    !night?
  end
  
  def self.sunrise_time
    calc_suntime
    @@sun_time.first
  end

  def self.sunset_time
    calc_suntime
    @@sun_time.second
  end
  
  
  private

  def self.calc_suntime
    return unless @@sun_time.nil? || @@sun_time[2].to_date!=Date.today

    latitude, longitude = Home.latitude, Home.longitude

    unless (latitude && longitude)
      raise 'Latitude or longitude is not defined'
    end

    sun_times = SunTimes.new
    day = Date.today
    @@sun_time = [sun_times.rise(day, latitude, longitude), sun_times.set(day, latitude, longitude), day]
  end

end