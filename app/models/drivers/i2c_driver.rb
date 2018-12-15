module I2cDriver

    mattr_accessor :i2c_installed
    mattr_accessor :i2c_devices
    self.i2c_devices = {}

    begin
	begin
	    require 'i2c'
	    self.i2c_installed = true
	rescue LoadError => e
	    puts e
	    self.i2c_installed = false
	    
	end
    end

    def set_driver_value(v)
	i2c_device.write(address_bin, (v.to_f.to_i))
    end

    def get_driver_value
	i2c_device.read_byte(address_bin)
    end

    def driver_value_to_value(driver_value)
	driver_value.is_a? String ? driver_value.unpack('c*') : driver_value.to_f
    end

    def i2c_write(*params)
	i2c_device.write(address_bin, *params)
    end

    def i2c_read(size, *params)
	i2c_device.read(address_bin, size, *params).unpack('c*')
    end

    def i2c_device
	self.i2c_devices[dev_address]
    end

    def address_bin
	address.to_i(16)
    end

    def dev_address
	'/dev/i2c-1'
    end

    def self.startup
	return unless i2c_installed

	devices.each do |device|
	    device_address = device.dev_address
	    unless i2c_devices[device_address]
		puts "create i2c device #{ device_address }"
		i2c_devices[device_address] = I2C.create(device_address)
	    end
	end
    end

    def self.devices
	Entity.where(driver: 'i2c', disabled: false).where.not(address: nil)
    end

end