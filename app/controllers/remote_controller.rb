class RemoteController < ApplicationController

  def execute
    entity_name = params[:entity]
    method_name = params[:method]
    method_params = params[:params]
    email = params[:email]
    pwd = params[:pwd]

    raise "Invalid authentication for user '#{ email }'" unless User.exists?(email: email, encrypted_password: pwd)

    ent = Entity[entity_name]
    raise "Invalid entity '#{ entity_name }'" unless ent

    render(plain: ent.public_send(method_name, *YAML.load(method_params)).to_yaml)
  rescue Exception => e
     render(plain: e.message, status: :not_implemented)
  end

end
