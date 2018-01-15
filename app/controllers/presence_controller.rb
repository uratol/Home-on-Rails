class PresenceController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :presence

  Entity.require_entity_classes
  
  def presence
    Person.where(address: params[:keyword]).each do |person|
      person.on!
    end
    head :ok, content_type: "text/html"
  end

end
