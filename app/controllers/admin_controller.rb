class AdminController < ApplicationController
  before_action :admin_user!

  def reboot
    `sudo reboot`
  end

end