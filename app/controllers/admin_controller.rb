class AdminController < ApplicationController
  before_action :admin_user!

  def reboot
    `sudo reboot`
    redirect_to_back
  end

end