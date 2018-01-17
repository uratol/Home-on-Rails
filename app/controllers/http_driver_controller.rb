class HttpDriverController < ApplicationController
  Entity.require_entity_classes
  skip_before_action :verify_authenticity_token, only: :ping

  def ping
    Entity.where(address: params[:keyword], driver: :http).each do |person|
      person.ping
    end

    head :ok, content_type: "text/html"
  end

end
