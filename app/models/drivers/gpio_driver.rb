require 'wiringpi' if Home::LINUX_PLATFORM 

module GpioDriver
  def set_driver_value v
    GpioDriver.io.digital_write(pin_no, transform_driver_value(v).to_i)
  end

  def get_driver_value
    return transform_driver_value(GpioDriver.io.digital_read(pin_no))
  end

  def self.watch
    startup
    
    @threads ||= []
    for t in @threads
      Thread.kill(t)
    end
    @threads = []  
    @threads << Thread.new do
      pins = sensors.uniq.pluck(:address)
      values = Array.new(pins.size)
      last_values = Array.new(pins.size)
      
      loop do
        pins.each_with_index do |pin, i|
          pin = map_pin(pin)
          last_values[i] = values[i]
          values[i] = io.digital_read(pin)
          if values[i] != last_values[i] && last_values[i]
            raise_pin(pin, values[i]) 
          end
          sleep(0.01)
        end
      end  
        
    end
  end if Home::LINUX_PLATFORM
  
  def self.raise_pin(pin, value)
    for e in devices.where(address: unmap_pin(pin))
      e.write_value e.transform_driver_value(value)
    end  
  end      

  def self.scan
    [*2..27]
  end

  def self.description
    'GPIO input pins will be always pulled up and have BCM numeration'
  end

  def self.description_data
    result = ''
    begin
      result += `gpio readall` 
    rescue Exception => e
      result += e.to_s   
    end
    begin
      result += `cat /sys/kernel/debug/gpio` 
    rescue Exception => e
      result += e.to_s   
    end
  end
  
  def pin_no
    GpioDriver.map_pin(address.to_i)
  end
  
  def self.bcm_pins
    @pin_map.values.uniq.sort
  end

  private
  
  def self.map_pin(pin)
    @pin_map.key(pin.to_i)
  end

  def self.unmap_pin(pin)
    @pin_map[pin.to_i]
  end

  def self.devices
    Entity.where(driver: :gpio).where.not(address: nil)
  end

  def self.sensors
    Sensor.where(driver: :gpio).where.not(address: nil)
  end
  
  def self.build_pin_map
    @pin_map ||= {}
    return @pin_map if @pin_map.any?
    100.times do |i|
      bcm_no = io.wpi_pin_to_gpio(i)
      @pin_map[i] = bcm_no if bcm_no>=0
    end  
    @pin_map
  end

  def self.startup
    $wiringpi_io ||= WiringPi::GPIO.new

    build_pin_map
    
    for e in GpioDriver.devices
      case e
      when Sensor
        io.pin_mode(e.pin_no, WiringPi::INPUT)
        io.pull_up_dn_control(e.pin_no, WiringPi::PUD_UP)
      when Actor   
        io.pin_mode(e.pin_no, WiringPi::OUTPUT)
      end
    end
  end
  
  def self.io
    #global variable usus for development autoload modules mode
    $wiringpi_io
  end
end

GpioDriver.startup if Home::LINUX_PLATFORM
