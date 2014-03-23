Bulldog::Application.routes.draw do

  as :user do
      patch '/user/confirmation' => 'confirmations#update', :via => :patch, :as => :update_user_confirmation
  end
  devise_for :users, path: "", controllers: {confirmations: 'confirmations',
                                              sessions: 'sessions'}

  get '/remote_sign_in' => 'remote_content#remote_sign_in', as: :remote_sign_in

  resources :accounts
  resources :bills, except: :show
  resources :customers, except: :show
  resources :invoices
  resources :reports, only: [:new, :create]
  get 'reports' => 'reports#new'
  resources :categories

end
