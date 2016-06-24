Rails.application.routes.draw do

  #Casein routes
  namespace :casein do
    resources :receipt_headers do
      member do
        get 'copy'
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
    end
    resources :planned_payment_headers do
      member do
        get 'new_by_last'
      end
    end
    resources :reports do
      collection do
        get 'pdf_list'
        get 'pdf_list2'
        get 'pdf_monthly'
        get 'pdf_payment_receipt'
        get 'csv_payment'
        get 'csv_receipt'
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
