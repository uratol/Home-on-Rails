LINUX_PLATFORM = RUBY_PLATFORM.match(/linux/)

require 'pi_piper' if LINUX_PLATFORM

module GpioDriver
  
  @@pins = {}
  
  def pin direction
    result = @@pins[pin_no] 
    result = @@pins[pin_no] = PiPiper::Pin.new(pin: pin_no, direction: direction) if !result || result.direction!=direction
    return result
  end
  
  def set_driver_value v
    pin(:out).update_value(invert_driver_value? ? 1-v : v)
  end

  def get_driver_value
    v = pin(:in).read
    return invert_driver_value? ? 1-v : v
  end

  def pin_no
     address.to_i
  end
  
  private

  #initialize watching  
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
            Entity.where(driver: :gpio, address: p.pin).each{|e| e.write_value p.value}
          end
        end    
      end if direction==:in

=begin      
      Thread.new(@@pins[entity.pin_no]) do |pin|
        pin.wait_for_change do
        end
        PiPiper.wait
      end if direction==:in
=end
    end  
  end if LINUX_PLATFORM
  
  puts "GPIO: initialize watching - complete"  
end
