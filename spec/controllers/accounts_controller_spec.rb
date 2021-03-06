require 'spec_helper'

describe AccountsController do
  login_user # so authenticate_user! works and sets @user


  describe "GET #show" do
    it "assigns the requested account as @account" do
      account = create(:account, user: @user)
      get :show, id: account
      expect(assigns(:account)).to eq account
    end

    it "renders the show template" do
      account = create(:account, user: @user)
      get :show, id: account
      expect(response).to render_template :show
    end
    it "only shows me accounts I own" do
      other_user = create(:user)
      account = create(:account)
      account2 = create(:account, user: other_user)
      request.env["HTTP_REFERER"]=root_path
      get :show, id: account2
      expect(response).to redirect_to root_path
    end
    it "doesn't expect hackers to have a valid HTTP_REFERER" do
      other_user = create(:user)
      account = create(:account)
      account2 = create(:account, user: other_user)
      #request.env["HTTP_REFERER"]=root_path
      get :show, id: account2
      expect(response).to redirect_to root_path
    end 
  end  

  describe "GET #new" do
    it "assigns an new account as @account" do
      get :new
      expect(assigns(:account)).to be_a_new(Account)
    end
  end

  describe "GET #edit" do
    it "assigns the requested account as @account" do
      account = create(:account, user: @user)
      get :edit, id: account
      expect(assigns(:account)).to eq account
    end

    it "renders the edit template" do
      account = FactoryGirl.create(:account, user: @user)
      get :edit, id: account
      expect(response).to render_template :edit
    end
  end

  it "doesn't edit someone elses's account" do
      other_user = create(:user)
      account2 = create(:account, user: other_user)
      request.env["HTTP_REFERER"]=root_path
      get :edit, id: account2
      expect(response).to redirect_to root_path
    end

  describe "POST #create" do

    context "with valid attributes" do
      it "saves the new account to the database" do
        expect{
          post :create, account: attributes_for(:account)
        }.to change(Account, :count).by(1)
      end
      it "redirects to show" do
        post :create, account: attributes_for(:account)
        expect(response).to redirect_to account_path(assigns(:account))
      end
    end

    context "with invalid attributes" do
      it "does not save the new account to the database" do
        expect{
          post :create, account: attributes_for(:account).merge(name: "")
        }.to_not change(Account, :count).by(1)
      end
      it "renders the new template" do
        post :create, account: attributes_for(:account).merge(name: "")
        expect(response).to render_template :new
      end
    end
  end

  describe "PATCH #update" do
    before :each do
      @account = create(:account, name: 'Test Account')
    end
    context "with valid attributes" do
      it "finds the account in question" do
        patch :update, id: @account, account: attributes_for(:account)
        expect(assigns(:account)).to eq(@account)
      end
      it "applies the requested changes" do
        patch :update, id: @account, account: attributes_for(:account,
          name: "New Account")
        @account.reload
        expect(@account.name).to eq "New Account"
      end
      it "redirects to the updated account" do
        patch :update, id: @account, account: attributes_for(:account)
        expect(response).to redirect_to @account
      end
    end
    context "with invalid attributes" do
      it "does not apply the requested changes" do
        patch :update, id: @account, account: attributes_for(:account,
          name: "")
        @account.reload
        expect(@account.name).to eq "Test Account"
      end
      it "renders the edit template" do
        patch :update, id: @account, account: attributes_for(:account,
          name: "")
        expect(response).to render_template :edit
      end
    end
  end

end
