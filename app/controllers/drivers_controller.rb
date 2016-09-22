class DriversController < ApplicationController
  def index
    @drivers = Entity.drivers_names
    @entity_counter = Entity.group(:driver).count
  end
  
  def show
    @driver_name = params[:id]
    @driver = (@driver_name.camelize + 'Driver').constantize
    @entities = Entity.where(driver: @driver_name).where.not(address: nil).to_a
    if @driver.respond_to? :scan
      @driver.scan.each do |driver_address|
        if driver_address.is_a? Hash
          driver_address = driver_address[:address]
        end
        driver_address = driver_address.to_s
        entity = @entities.detect{|e| e.address == driver_address}
        unless entity
          entity = Device.new
          @entities << entity
        end
        entity.driver_address = driver_address
      end
    end
  end
end
