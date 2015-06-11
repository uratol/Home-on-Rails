class HttpDriverController < ApplicationController
  Entity.require_entity_classes
  
  def read 
    name, addr, val = params[:name], params[:addr], params[:val].to_f
    @device = Entity[name] if name
    @device ||= Entity.find_by address: addr if addr
    if !@device
      mess = "Device not found: #{ request.original_url }"
      Rails.logger.error mess
      
      render json: mess, status: :unprocessable_entity
      return
    end
    
    @device.store_value val
    render nothing: true
  end
  
  def write
    
  end
  
end
