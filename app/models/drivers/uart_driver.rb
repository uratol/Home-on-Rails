require 'rubyserial'

module UartDriver
  
  def set_driver_value v
    v = [v].pack('c')
    UartDriver.get_port(address).write(v)
    puts v.inspect
  end

  def self.description
    "Serial port driver"
  end
  
  def self.scan
    ['/dev/serial0', '/dev/serial1']
  end
  
  def self.get_port address
    @@ports ||= {}
    p = @@ports[address]
    unless p
      p = Serial.new(address, 9600, 8)
      @@ports[address] = p
    end
    return p
  end 
  
end