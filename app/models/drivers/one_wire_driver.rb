module OneWireDriver
  
  DEVICE_ROOT = Home::LINUX_PLATFORM ? '/sys/bus/w1/devices/' : 'c:/Temp/w1/devices/'
  
  
  def set_driver_value v
  end

  def get_driver_value
    file = File.new(DEVICE_ROOT + address + '/w1_slave')
    puts file
    file_data = file.read
    return file_data.split( 't=' ).last.to_f / 1000
  rescue Errno::ENOENT
  end

  def pin_no
     address.to_i
  end
  
  def self.scan
    result = []
    Dir[ DEVICE_ROOT + '*-*' ].each do | path |
      basename = Pathname(path).basename.to_s
      e = Entity.where(driver: 'one_wire', address: basename).limit(1).first
      unless e 
        e = Entity.new unless e
        e.address = basename
      end
      result << e
    end  
    return result
  end
end