require 'timedcache'

module DhtDriver

  mattr_accessor :dht_installed

  begin
    require 'dht-sensor-ffi' #if Home::LINUX_PLATFORM
    self.dht_installed = true
  rescue LoadError => e
    puts e
    self.dht_installed = false
  end

  CACHE = TimedCache.new(default_timeout: 15.seconds, type: :file, filename: 'tmp/dht_driver.cache')

  def poll
    super
  end

  def get_driver_value
    a = address.split(':')
    model = a.first.to_i
    pin_no = a.second.to_i
    
    begin
      r = CACHE[pin_no] 
    rescue ArgumentError # marshal data too short
      r = nil
    end  
    
    unless r
      r = DhtSensor.read(pin_no, model)
      return if r.humidity > 100
      CACHE[pin_no] = r  
    end  
     
    case self
      when Temperature then r.temperature
      when Humidity then r.humidity
      else nil
    end
  end
  
  def self.models
    [11,22]
  end
  
  def self.description_data
    "DHT-XX type humidity/temperature sensor
    Address format: XX:P 
    where XX - kind of sensor, #{ models.join(" or ") }
    P - GPIO BCM pin number
    Current GPIO pin configuration:
    " + GpioDriver.description_data
  end
  
  def self.scan
    
# too slow: DhtSensor.read lock all threads    
=begin    
    threads = []
    GpioDriver.bcm_pins.each do |pin|
      threads << Thread.new(pin) do |pin_no|
        print "scanning pin #{ pin_no }\n"
        begin
          byebug
          DhtSensor.read(pin_no, models.first)
        rescue
        else
          Thread.current[:pin_no] = pin_no
        end       
      end
    end
    pins = []
    threads.each do |t|
      print "join thread #{ t }\n"
      t.join(10.seconds)
      pin_no = t[:pin_no]
      print "joined pin #{ pin_no }\n"
      pins << pin_no if pin_no
    end  
    pins
=end    
    
    
    result = []
    models.map do |model|
      result += GpioDriver.bcm_pins.map{|p| "#{ model }:#{ p }"}
    end  
    result
  end
  
end