=begin
require_relative '../spec_helper'

require 'entity'

describe MqttDriver, type: :model do
  e = Entity.new(name: 'test', driver: 'mqtt')

  puts "!= #{ e.get_driver_value }"
end
=end

require_relative '../../app/models/drivers/mqtt_driver'

=begin
class MqttTest

  def initialize
    extend(MqttDriver)
  end

end

mqttObject = MqttTest.new

puts mqttObject.get_driver_value
=end
