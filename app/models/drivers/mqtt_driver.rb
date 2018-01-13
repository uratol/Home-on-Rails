require 'mqtt'


=begin
# Publish example
MQTT::Client.connect('test.mosquitto.org') do |c|
  c.publish('test', {method: :send, param1: 10.3})
end

# Subscribe example
MQTT::Client.connect('test.mosquitto.org') do |c|
  # If you pass a block to the get method, then it will loop
  c.get('test') do |topic,message|
    puts "#{topic}: #{message}"
    false
  end
end
=end


module MqttDriver
  DEFAULT_BROKER_ADDRESS = 'localhost'
  DEFAULT_BROKER_PORT = 1883

  mattr_accessor :brokers
  self.brokers = {}

  def self.startup
    devices.each do |device|
      broker_addr = device.broker_address.strip
      unless brokers[broker_addr]
        puts "mqtt broker will be connected: #{ broker_addr }"
        begin
          brokers[broker_addr] = MQTT::Client.connect(host: broker_addr, port: device.broker_port, username: device.broker_username , password: device.broker_password)
        rescue Exception => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end
  end

  def self.watch(&block)
    @threads.each(&:kill) if (@threads ||= []).any?
    puts "MQTT sensors #{ sensors.pluck(:name).join(',') } will be watching"
    sensors.each do |sensor|
      @threads << Thread.new(block, sensor) do |trigger, entity|
        begin
          entity.broker.get(entity.address) do |topic,message|
            trigger.call(topic, message)
          end
        rescue Exception => e
          puts e
          Rails.logger.error(e)
        end
      end
    end
    @threads.each(&:join)
  end

  def self.devices
    Entity.where(driver: :mqtt, disabled: false).where.not(address: nil)
  end

  def self.sensors
    Sensor.where(driver: :mqtt).where.not(address: nil)
  end

  def driver_value_to_value(driver_value)
    v = case driver_value
          when 'OFF'
            0
          when 'ON'
            1
          else
            driver_value
        end
    invert? ? 1 - v : v if v
  end

  def broker_address
    DEFAULT_BROKER_ADDRESS
  end

  def broker_port
    DEFAULT_BROKER_PORT
  end

  def broker_username
    Home.mqtt_username
  end

  def broker_password
    Home.mqtt_password
  end

  def set_driver_value(v)
    broker.connect unless broker.connected?
    broker.publish(address, v)
  end

  def broker
    self.brokers[broker_address]
  end

end

MqttDriver.startup if Rails.env.development?
