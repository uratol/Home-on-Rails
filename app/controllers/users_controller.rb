class UsersController < ApplicationController

  before_action :admin_user!
  before_action :set_user, only: [:edit, :update, :destroy]

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
    if @user.destroy
      er, notice = nil, 'User was successfully destroyed.'
    else
      er, notice = @user.errors.full_messages.join, nil
    end
    redirect_to_back notice: notice, alert: er
  end
    
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
     params_user = params.require(:user).permit(:name, :email, :isadmin, :password)
     if params_user[:password].blank?
       params_user.except! :password
     end
     params_user
  end
  
end
