Rails.application.routes.draw do

  #Casein routes
  namespace :casein do
    resources :bank_transfers, only: [:new, :create]

    resources :bank_account_balances, only: :index do
      collection do
        patch :update_all
        get :pdf
      end
    end

    resources :receipt_headers do
      member do
        get 'copy'
        get 'pdf'
      end
    end

    resources :my_accounts
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
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'casein/casein#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
