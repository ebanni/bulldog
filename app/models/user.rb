class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :confirmable, :timeoutable

  has_one :account

  # validates :email, uniqueness: true # apparently handled by Devise!
  # accepts_nested_attributes_for :account
  attr :account_name

  def after_database_authentication
    # set current_account here ?
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

    # new function to set the password without knowing the current password used in our confirmation controller. 
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  def account_set_up(params)
    p = {}
    p[:user_id] = id
    p[:name] = params[:account_name]
    Account.create(p) unless self.account.present?
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end
  
  def password_required?
  # Password is required if it is being set, but not for new records
    if !persisted? 
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end
end
