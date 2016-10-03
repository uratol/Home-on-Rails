require 'wiringpi' if Home::LINUX_PLATFORM 

module GpioDriver
  def set_driver_value v
    GpioDriver.io.digital_write(pin_no, transform_driver_value(v).to_i)
  end

  def get_driver_value
    return transform_driver_value(GpioDriver.io.digital_read(pin_no))
  end

  def self.watch &block
    startup
    
    pins = sensors.uniq.pluck(:address).map(&:to_i)
    
    @threads.each(&:kill) if (@threads ||= []).any?
    
    pins.each_with_index do |unmaped_pin|
      @threads << Thread.new(block) do |trigger|
        maped_pin = map_pin(unmaped_pin)
        value = nil
        loop do
          last_value = value
          value = io.digital_read(maped_pin)
          if value != last_value
            trigger.call(unmaped_pin, value)
          end
          sleep(0.01)
        end
      end
    end
    @threads.each(&:join)
  end if Home::LINUX_PLATFORM
  
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
      else
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

