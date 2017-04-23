class RemoteController < ApplicationController

  def execute
    entity_name = params[:entity]
    method_name = params[:method]
    method_params = params[:params]
    email = params[:email]
    encrypted_password = params[:pwd]

    authenticate!(email, encrypted_password)

    ent = Entity[entity_name]
    raise "Invalid entity '#{ entity_name }'" unless ent

    render(plain: ent.public_send(method_name, *YAML.load(method_params)).to_yaml)
  rescue Exception => e
     render(plain: e.message, status: :not_implemented)
  end

  private

  def authenticate!(email, pwd)
    main_admin = User.where(isadmin: true).first

    raise_authentication(email) if main_admin.email != email

    if main_admin.encrypted_password != pwd
      remote_user_email = 'remote.' + email
      remote_user = User.find_by(email: remote_user_email)

      raise_authentication(email) if remote_user && remote_user.encrypted_password != pwd

      if remote_user.nil? # if logged in first time - create login stub
        User.create!(name: 'Remote '+ main_admin.name, email: remote_user_email, isadmin: false, encrypted_password: pwd)
      end
    end
  end

  def raise_authentication(email)
    raise "Invalid authentication for user '#{ email }'"
  end

end
