class User < ActiveRecord::Base
  
  require 'devise'

  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable
    #, :registerable
        #, :registerable, :recoverable, :validatable, :trackable

  scope :admins, ->{ where(isadmin: true) }

end
