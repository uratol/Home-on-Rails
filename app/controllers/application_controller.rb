class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  before_action(:authenticate_user!, except: [:execute, :presence])
  
  def admin_user!
    redirect_to root_path if !isadmin?
  end

  def isadmin?
    current_user.try :isadmin
  end

end
