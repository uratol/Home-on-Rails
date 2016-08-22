require 'pi_piper' if Home::LINUX_PLATFORM

module GpioDriver
  
  @@pins = {}
  
  def pin direction
    result = @@pins[pin_no] 
    result = @@pins[pin_no] = PiPiper::Pin.new(pin: pin_no, direction: direction) if !result || result.direction!=direction
    return result
  end
  
  def set_driver_value v
    pin(:out).update_value(transform_driver_value(v))
  end

  def get_driver_value
    return transform_driver_value(pin(:in).read)
  end

  def pin_no
     address.to_i
  end
  
  def watch
    return if !Home::LINUX_PLATFORM
    direction = case self
                when Sensor
                  :in 
                when Actor 
                  :out
              end
    puts "direction= #{direction}; #{ self.inspect }"              
    
    if direction          
      @@pins[pin_no] = PiPiper::Pin.new(pin: pin_no, direction: direction)
      
      PiPiper.watch(pin: pin_no) do |pin|
        Thread.new(pin) do |p|
          Thread.exclusive do
            Entity.where(driver: :gpio, address: p.pin).each{|e| e.write_value e.transform_driver_value(p.value)}
          end
        end
      end if direction==:in
    end
    true  
  end
  
  private

  Entity.where(driver: :gpio).where.not(address: nil).each do |e|
    puts "GPIO: unexport #{ e.pin_no } pin"
    File.open("/sys/class/gpio/unexport", "w") { |f| f.write("#{e.pin_no}") }
  end

  #initialize watching  
=begin      
  puts "GPIO: initialize watching..."  
  
  for entity in Entity.where(driver: :gpio).where.not(address: nil)
    direction = case entity
                when Sensor
                  :in 
                when Actor 
                  :out
              end
    puts "direction= #{direction}; #{ entity.inspect }"              
    
    if direction          
      @@pins[entity.pin_no] = PiPiper::Pin.new(pin: entity.pin_no, direction: direction)
      
      PiPiper.watch(pin: entity.pin_no) do |pin|
        Thread.new(pin) do |p|
          Thread.exclusive do
            Entity.where(driver: :gpio, address: p.pin).each{|e| e.write_value e.transform_driver_value(p.value)}
          end
        end    
      end if direction==:in
    end  
  end if Home::LINUX_PLATFORM
  
  puts "GPIO: initialize watching - complete"
=end    
end
