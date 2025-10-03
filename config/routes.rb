Rails.application.routes.draw do
  # OAuth routes (NationBuilder App Store integration)
  get "/", to: "o_auth#install", as: :root
  get "/oauth/callback", to: "o_auth#callback", as: :oauth_callback
  delete "/uninstall", to: "o_auth#uninstall", as: :uninstall
  
  # Application routes
  get "/dashboard", to: "dashboard#show", as: :dashboard
  
  # Health check for monitoring
  get "up" => "rails/health#show", as: :rails_health_check
  
  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
