class AccountsController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    @account = Account.owned_by_user(current_user).find(params[:id])
  end

  def new
    plan = Plan.find(params[:plan_id])
    @account = plan.accounts.build
    @title = params[:title]
    @price = params[:price]
    @interval = params[:interval]
  end

  def edit
    @account = Account.owned_by_user(current_user).find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    # if @account.plan_id_changed?
    #   if @account.process_changes
    #     redirect_to @account, notice: "Account successfully updated"
    #   else
    #     render 'edit'
    #   end
    # else # only changing name or VAT flag
      if @account.update(account_params)
        if @account.active?
          redirect_to @account, notice: "Account successfully updated"
        else
          sign_out current_user
          redirect_to page_path('goodbye')
        end
      else
        if params[:account][:plan_id] == "0" # the action was a cancellation
          flash[:error] = "There was a problem with this transaction"
          render 'show'
        else
          flash[:error] = "There was a problem with this transaction"
          render 'edit'
        end
      end
    # end
  end

  def create
    @account = Account.new(account_params)
    if @account.valid?
      sub = @account.process_subscription
      if sub && @account.save
        @account.create_user
        redirect_to home_path, 
        notice: "Thanks for subscribing. A confirmation link has been sent to your email address. Please open the link to activate your account."
      else
        flash[:error] = @account.errors[:base][0]
        render 'new'
      end
    else
      flash[:error] = @account.errors[:base][0]
      render 'new'
    end
  end

  def cancel
    @account = Account.owned_by_user(current_user).find(params[:id])
  end

  private

  def account_params
    params.require(:account).permit(:name, :address, :postcode, 
      :include_bank, :bank_account_name, :bank_name, :bank_address, 
      :bank_account_no, :bank_sort, :bank_bic, :bank_iban, :invoice_heading,
      :vat_enabled, :plan_id, :email, :stripe_customer_token, :user_id,
      :stripe_card_token, :title, :price, :interval)
  end

  def record_not_found
    flash[:error] = "You don't have access to that account"
    begin
      redirect_to :back
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end
end
