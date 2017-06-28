class NetworksController < ApplicationController

  before_action :admin_user!

  def edit
    @network = Network.new
  end

  def update
    redirect_to network_edit_path
  end

end