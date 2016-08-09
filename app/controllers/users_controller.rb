class UsersController < ApplicationController

  before_action :admin_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      edit
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      edit
      render :edit
    end
  end  

  def destroy
    if !@user.destroy
      er, notice = @user.errors.full_messages.join, nil
    else
      er, notice = nil, 'User was successfully destroyed.'
    end
    redirect_to :back, notice: notice, alert: er
  end
    
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
     p = params.require(:user).permit(:name, :email, :isadmin, :password)
     if p[:password].blank?
       p.except! :password 
     end
     return p
#    et = Entity.entity_types.map{|e| e.downcase } << 'entity'
#    params.require(params.find{|key, value| et.include? key}[0]).permit(:name, :type, :caption, :address, :left, :top, :value, :parent_id)
  end
  
end
