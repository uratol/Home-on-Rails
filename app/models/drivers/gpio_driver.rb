require 'pi_piper' if Home::LINUX_PLATFORM

module GpioDriver
  
  @@pins = {}
  
  def self.get_pin direction, pin_no
    result = @@pins[pin_no]
    pull = direction == :in ? :up : :off
    result = @@pins[pin_no] = PiPiper::Pin.new(pin: pin_no, direction: direction, pull: pull) if !result || result.direction!=direction
    return result
  end
  
  def set_driver_value v
    GpioDriver.get_pin(:out, pin_no).update_value(transform_driver_value(v))
  end

  def get_driver_value
    return transform_driver_value(GpioDriver.get_pin(:in, pin_no).read)
  end

  def pin_no
     address.to_i
  end
  
  
  def self.watch
    Sensor.where(driver: :gpio).where.not(address: nil).uniq.pluck(:address).each do |pin_str|
      begin
        unexport(pin_str)
        pin_watch pin_str.to_i do |pin|
          begin
            puts 'switch!'
            puts "before: #{Entity.wc_door.value}"
            Entity.where(driver: :gpio, address: pin.pin).each{|e| e.write_value e.transform_driver_value(pin.value)}
            puts "after: #{Entity.wc_door.value}"
          rescue Exception => e
            puts e.message
            Rails.logger.error e.message
          end     
        end
        puts "GPIO: watch pin=#{ pin_str }"
        
=begin        
        PiPiper.watch(pin: pin_str.to_i) do |pin|
          no, value = pin.pin, pin.value
          puts "GPIO: changed #{ no } pin, value: #{ value }"
          
          begin
            Thread.new(no, value) do |pin_no, pin_value|
              begin
                Thread.exclusive do
                  begin
                    Entity.where(driver: :gpio, address: pin_no).each{|e| e.write_value e.transform_driver_value(pin_value)}
                  rescue
                    puts "in exclusive"
                  end  
                end
              rescue
                puts "in thread"
              end  
            end
          ensure
            Rails.logger.flush
          end        
        end
=end        
      rescue Exception => e
        s = "Error watching gpio pin #{ pin_str }: #{ e.message }"
        puts s
        Rails.logger.error s
      end
    end
  end
  
  def self.pin_watch(pin_no, &block)
    pin = get_pin(:in, pin_no)
    new_thread = Thread.new(pin) do |xpin|
      
      begin
        loop do
          xpin.wait_for_change
          block.call xpin
        end
      rescue Exception => e
        s = "Error watching gpio pin in thread #{ xpin.pin }: #{ e.message }"
        puts s
        Rails.logger.error s        
      end
    end
    new_thread.abort_on_exception = true
    new_thread
  end

  def self.unexport pin
    if File.exist? "/sys/class/gpio/gpio#{ pin }"
      puts "GPIO: unexport #{ pin } pin"
      File.open("/sys/class/gpio/unexport", "w") { |f| f.write("#{pin}") }
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
  
  private

=begin  
  Entity.where(driver: :gpio).where.not(address: nil).each do |e|
    e.unexport
  end
=end

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
