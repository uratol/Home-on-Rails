# Драйвер, позволяющий определять доступность ip-адреса в сети
# может использоваться для определения наличия человека в доме по доступности мобильного телефона
# для этого в роутере для мобильного телефона задаётся фиксированный ip-адрес
# и этот ip-адрес записывается в поле "address" текущего объекта.

module PingDriver

  require 'net/ping'

  def self.extended(base)
    ip_block = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
    ip_mask = /\A#{ip_block}\.#{ip_block}\.#{ip_block}\.#{ip_block}\z/
    base.singleton_class.validates :address, presence: true, format: { with: ip_mask }
    base.binary = true
  end

  def get_driver_value
    icmp.ping ? 1 : 0
  end

  alias_method :ping?, :get_driver_value

  def ping
    icmp.ping
  end

  private

  def icmp
    unless @icmp
      @icmp = Net::Ping::ICMP.new(address)
      @icmp.timeout = 1
    end

    @icmp
  end

end

=begin

class TestPing
  attr_accessor(:binary)

  def initialize
    extend(PingDriver)
  end

  def address
    '192.168.0.102'
  end

end

p = TestPing.new

while true do
  puts "ping: #{ p.get_driver_value }"
  sleep(1)
end
=end
