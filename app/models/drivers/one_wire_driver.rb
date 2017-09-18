module OneWireDriver
  
  DEVICE_ROOT = Home::LINUX_PLATFORM ? '/sys/bus/w1/devices/' : 'c:/Temp/w1/devices/'
  
  
  def set_driver_value v
  end

  def get_driver_value
    file = File.new(DEVICE_ROOT + address + '/w1_slave')
    puts file
    file_data = file.read

    return file_data.split( 't=' ).last.to_f / 1000 if file_data.include? 'YES'
  rescue Errno::ENOENT => e
    puts e
  end

  def self.scan
    Dir[ DEVICE_ROOT + '*-*' ].each.map{|path| Pathname(path).basename.to_s}
  end
end