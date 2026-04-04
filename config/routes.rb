Rails.application.routes.draw do
  root "employees#index"

  resources :employees do
    collection do
      get :insights
    end
  end
end
