class HttpDriverController < ApiController
  Entity.require_entity_classes

  def ping
    Entity.where(address: params[:address], driver: :http).each do |person|
      person.ping
    end

    head :ok, content_type: "text/html"
  end

end
