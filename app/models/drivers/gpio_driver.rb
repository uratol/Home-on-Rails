# Драйвер обеспечивает прямой доступ к портам ввода-вывода GPIO (general-purpose input/output).
# В адресе указывается номер пина по BCM-нумерации
# При инициализации порта, указанного в адресе, устанавливает подтяжку по напряжению (pull up)
module GpioDriver

  mattr_accessor :gpio_installed

  begin
    require 'wiringpi'
    self.gpio_installed = true
  rescue LoadError => e
    puts e
    self.gpio_installed = false
  end

  def set_driver_value(v)
    GpioDriver.io.digital_write(pin_no, transform_driver_value(v).to_i) if self.gpio_installed
  end

  def get_driver_value
    transform_driver_value(GpioDriver.io.digital_read(pin_no))
  end

  def self.watch(&block)
    startup

    pins = sensors.uniq.pluck(:address).map(&:to_i)
    
    @threads.each(&:kill) if (@threads ||= []).any?

    puts "GPIO pins #{ pins } will be watching"
    
    pins.each do |unmapped_pin|
      @threads << Thread.new(block) do |trigger|
        mapped_pin = map_pin(unmapped_pin)
        value = nil
        puts "loop pin #{ unmapped_pin }(#{ mapped_pin })"
        loop do
          last_value = value
          value = io.digital_read(mapped_pin)
          if value != last_value
            trigger.call(unmapped_pin, value)
          end
          sleep(0.01)
        end
      end
    end
    @threads.each(&:join)
  end if self.gpio_installed
  
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
      result + e.to_s
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
    return unless GpioDriver.gpio_installed
    $wiringpi_io ||= WiringPi::GPIO.new

    build_pin_map
    
    for e in GpioDriver.devices
      case e
      when Sensor
        io.pin_mode(e.pin_no, WiringPi::INPUT)
        io.pull_up_dn_control(e.pin_no, WiringPi::PUD_UP)
      else
        io.pin_mode(e.pin_no, WiringPi::OUTPUT)
        io.digital_write(e.pin_no,e.transform_driver_value(e.value).to_i) if e.value
      end
    end
  end
  
  def self.io
    #global variable used for development autoload modules mode
    $wiringpi_io
  end
end

GpioDriver.startup

