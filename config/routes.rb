Rails.application.routes.draw do

  #Casein routes
  namespace :casein do
    resources :bank_transfers, only: [:index, :show, :new, :create, :destroy]

    resources :bank_account_balances, only: :index do
      collection do
        patch :update_all
        get :pdf
      end
    end

    resources :receipt_headers do
      member do
        get :copy
        get :plan_pdf
        get :invoice_pdf
      end
      collection do
        post :duplicate_monthly_data
      end
    end

    resources :my_accounts
    resources :my_corporations
    resources :accounts
    resources :items
    resources :projects
    resources :payment_headers do
      member do
        get 'pdf'
        get 'new_by_last'
      end
      collection do
        post :duplicate_monthly_data
      end
    end

    resources :not_processed_payment_headers, only: [:index] do
      collection do
        patch :update_all, as: :update_all
      end
    end

    resources :reports do
      collection do
        get 'pdf_each_project_payment'
        get 'pdf_each_project_receipt'
        get 'pdf_each_day_payment'
        get 'pdf_each_day_receipt'
        get 'pdf_payment_receipt'
        get 'csv_payment'
        get 'csv_receipt'
        get 'pdf_not_processed_payment'
        get 'pdf_processed_payment'
        get 'pdf_each_bank_payment_receipt'
      end
    end
  end

  # Load other routes
  Dir.glob(File.expand_path("#{Rails.root}/config/routes/**/*.rb", __FILE__)).each do |file|
    instance_eval(File.read(file))
  end

  root 'casein/casein#index'

  get '*path' => 'errors#render_404', constraints: Casein::RouteConstraint.new
  put '*path' => 'errors#render_404', constraints: Casein::RouteConstraint.new
  post '*path' => 'errors#render_404', constraints: Casein::RouteConstraint.new
  patch '*path' => 'errors#render_404', constraints: Casein::RouteConstraint.new
  delete '*path' => 'errors#render_404', constraints: Casein::RouteConstraint.new
end
