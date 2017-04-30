class Clock < Widget
  require 'solar'
  
  @sun_time = nil
  
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
    @sun_time[:rise]
  end

  def self.sunset_time
    calc_suntime
    @sun_time[:set]
  end

  def self.noon_time
    calc_suntime
    @sun_time[:noon]
  end

  def self.sun_elevation
    Solar.position(Time.now, Home.longitude, Home.latitude).first
  end

  def self.sun_azimuth
    Solar.position(Time.now, Home.longitude, Home.latitude).second
  end

  private

  def self.calc_suntime
    day = Date.today
    return unless @sun_time.nil? || @sun_time[:day] != day

    latitude, longitude = Home.latitude, Home.longitude

    unless latitude && longitude
      raise 'Latitude or longitude is not defined'
    end

    @sun_time = {}
    @sun_time[:rise], @sun_time[:noon], @sun_time[:set] = Solar.passages(day, longitude, latitude)
    @sun_time[:day] = day

    #sun_times = SunTimes.new
    #@sun_time = [sun_times.rise(day, latitude, longitude), sun_times.set(day, latitude, longitude), day]
  end

end