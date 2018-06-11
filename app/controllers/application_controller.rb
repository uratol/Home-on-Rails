class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

#  skip_before_action :verify_authenticity_token
  protect_from_forgery prepend: true#, with: :exception

  before_action(:authenticate_user!, except: [:execute])
  
  def admin_user!
    redirect_to root_path unless isadmin?
  end

  def isadmin?
    current_user.try :isadmin
  end

  def redirect_to_back(options = {})
    if respond_to? :redirect_back
      redirect_back(fallback_location: (options[:fallback_location] || root_path), **options)
    else
      redirect_to :back, options
    end
  end


end
