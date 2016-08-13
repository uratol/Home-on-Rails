class DriversController < ApplicationController
  def index
    @drivers = Entity.entity_drivers
    @entity_counter = Entity.group(:driver).count
  end
  
  def show
    @driver = (params[:id].camelize + 'Driver').constantize
  end
end
